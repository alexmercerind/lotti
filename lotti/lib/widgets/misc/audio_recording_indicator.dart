import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lotti/blocs/audio/recorder_cubit.dart';
import 'package:lotti/blocs/audio/recorder_state.dart';
import 'package:lotti/theme.dart';
import 'package:lotti/widgets/journal/entry_tools.dart';

class AudioRecordingIndicator extends StatelessWidget {
  const AudioRecordingIndicator({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AudioRecorderCubit, AudioRecorderState>(
      builder: (BuildContext context, AudioRecorderState state) {
        if (state.status != AudioRecorderStatus.recording) {
          return const SizedBox.shrink();
        }

        return Positioned(
          right: MediaQuery.of(context).size.width / 2 - 110,
          bottom: 0,
          child: MouseRegion(
            cursor: SystemMouseCursors.click,
            child: GestureDetector(
              onTap: () {
                context.read<AudioRecorderCubit>().stop();
              },
              child: ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(8),
                  topRight: Radius.circular(8),
                ),
                child: Container(
                  width: 120,
                  height: 32,
                  color: AppColors.timeRecordingBg,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Icon(
                            Icons.mic,
                            size: 24,
                            color: AppColors.editorTextColor,
                          ),
                          Padding(
                            padding: const EdgeInsets.only(left: 4.0),
                            child: Text(
                              formatDuration(state.progress),
                              style: TextStyle(
                                fontFamily: 'ShareTechMono',
                                fontSize: 18.0,
                                color: AppColors.editorTextColor,
                              ),
                            ),
                          ),
                        ],
                      ),
                      VuMeterWidget(
                        decibels: state.decibels,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class VuMeterWidget extends StatelessWidget {
  double decibels = 0;
  VuMeterWidget({Key? key, required this.decibels}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 140,
      child: LinearProgressIndicator(
        value: decibels / 160,
        minHeight: 6.0,
        color: (decibels > 130)
            ? AppColors.audioMeterPeakedBar
            : (decibels > 100)
                ? AppColors.audioMeterTooHotBar
                : AppColors.audioMeterBar,
        backgroundColor: AppColors.vuBgColor,
      ),
    );
  }
}
