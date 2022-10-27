# DispatchSourceDemo

Playing with DispatchSource, using a file and FSEvents to "pipe" data between text editors.

![dispatch](https://user-images.githubusercontent.com/3140681/198331032-5f40d4f3-5a4c-4d1d-9916-81f2a46f4bf5.gif)


## Why would you want this?

I think it's cool to have the file as the source of truth, rather than say, setting the value on a @Published and writing to disk as a side effect.

You could throttle this and perform (de-)serialization rather than save objects to UserDefaults.

