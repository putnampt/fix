fix: A simple fixation task template based on the `ptb` library.

`fix` implements a bare-bones fixation task. A random image is presented and must be continuously "fixated" (using mouse input to represent gaze position) for 300ms, before a time-limit of 2000ms elapses. If the subject is successful, a success feedback cue is presented, otherwise an error feedback cue is presented. This trial sequence repeats indefinitely, until the escape key is pressed.

We use this as a demonstration of a state-machine program built with the `ptb` library. Image presentation, success-feedback presentation, and error-feedback presentation are each associated with a state (concretely, a `ptb.State` object) which performs some action(s) a) upon entry into the state, b) repeatedly, while the state is executing, and c) upon exit out of the state. These otherwise independent states are sequenced to create and control the flow of the task.

This code depends on:
* [ptb](https://github.com/nfagan/ptb)
* [Psychtoolbox](http://psychtoolbox.org)
* [shared_utils](https://github.com/nfagan/shared_utils)

Make sure these libraries are downloaded and added to MATLAB's search path before running this example.
