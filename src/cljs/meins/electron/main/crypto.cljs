(ns meins.electron.main.crypto
  (:require [taoensso.timbre :refer-macros [info debug error warn]]
            ["keytar" :as keytar :refer [setPassword getPassword]]
            [meins.shared.encryption :as mse]))

(defn save-key-pair [key-pair]
  (let [{:keys [publicKey secretKey]} key-pair]
    (setPassword "meins" "publicKey" publicKey)
    (setPassword "meins" "secretKey" secretKey)))

(defn get-secret-key []
  (getPassword "meins" "secretKey"))

(defn get-public-key []
  (getPassword "meins" "publicKey"))

(defn create-keypair [{:keys []}]
  (let [key-pair (mse/gen-key-pair-hex)]
    (save-key-pair key-pair)
    (info "created key pair, public key:" (:publicKey key-pair))
    {}))

(defn get-cfg [{:keys [current-state]}]
  {:emit-msg [:crypto/cfg (select-keys current-state [:publicKey :secretKey])]})

(defn state-fn [_put-fn]
  (let [state (atom {})]
    (-> (get-secret-key)
        (.then #(swap! state assoc :secretKey %)))
    (-> (get-public-key)
        (.then #(swap! state assoc :publicKey %)))
    {:state state}))

(defn cmp-map [cmp-id]
  {:cmp-id      cmp-id
   :state-fn    state-fn
   :handler-map {:crypto/create-keys create-keypair
                 :crypto/get-cfg     get-cfg}})
