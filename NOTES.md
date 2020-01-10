## AVAudioSession

* session for the current audio-usage of the app
* each iOS app is implicitly given one, as a Singleton
* changing the mode optimizes usage for a specific use-case


## AVAudioRecorder

* audio recorder
* call `record` to start recording to the file described
* call `stop` to end recording and close the file
* uncertain of what happens if recording starts again, can change url, etc.


## [CADisplayLink](https://developer.apple.com/documentation/quartzcore/cadisplaylink)

* "A timer object that allows your application to synchronize its drawing to the refresh rate of the display."
* uses RunLoops
    * use main runloop for UI stuff, or it doesn't render, huh?

