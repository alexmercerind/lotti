(ns meins.ui.elements.qr
  (:require ["react-native-qrcode-svg" :as qr]
            [meins.ui.shared :refer [set-clipboard touchable-opacity]]
            [meins.util.keychain :as kc]
            [re-frame.core :refer [subscribe]]
            [reagent.core :as r]))

(def qr-svg (r/adapt-react-class (aget qr "default")))

(defn qr-code [_]
  (let [instance-id (subscribe [:instance-id])]
    (fn qr-code-render [public-key]
      (when public-key
        (let [qr-value (pr-str {:publicKey public-key
                                :node-id   @instance-id})]
          [touchable-opacity {:on-press #(set-clipboard qr-value)
                              :style    {:background-color "white"
                                         :padding          20
                                         :border-radius    18
                                         :align-items      "center"}}
           [qr-svg {:value qr-value
                    :size  300}]])))))
