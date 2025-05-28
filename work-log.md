# MapDesk

## Initial Thoughts

I’d like to start building a Flutter app for Mac OSX desktop that uses maps and GPX data.

This might be useful: https://pub.dev/documentation/base_map_osm_google/latest/

Another useful tool, apparently, is `flutter_map` -- see https://medium.com/@paudyal.gaurab11/integrating-open-street-map-in-flutter-3df2da85136f

flutter_map seems like the tool to use: https://pub.dev/packages/flutter_map

It works on Mac OS desktop, as well as web, iOS, etc.

Nice!

Yup, this is definitely the tool to use.

## Scoping for initial app

Should I start with a simple “Hello World” app, and then build up from there?

Let’s try following an example:

- https://medium.com/@vikranthsalian/boost-flutter-development-with-cursor-ai-full-guide-steps-2025-660951fa12f1

This assumes I have Flutter installed.  Let’s start with doing that.

## Installing Flutter

To use Flutter, I need to install the following:

- XCode
		- Ouch.  Okay, it’s a 3.2 gigabyte download
		- Wow...it was actually pretty fast, only about 5 minutes.
		- I only installed for Mac OS X development, not for iOS which is another 8 gigabytes.
- Cocoapods
		- Should be installed via `sudo gem install cocoapods`
		- Hmmm...this needs a newer version of Ruby than what I have installed on my computer.
		- They recommend either using homebrew, or a Ruby version manager such as RVM.
		- So I’ll try using RVM (https://rvm.io):
				- gpg2 --keyserver keyserver.ubuntu.com --recv-keys 409B6B1796C275462A1703113804BB82D39DC0E3 7D2BAF1CF37B13E2069D6956105BD0E739499BDB
				- \curl -sSL https://get.rvm.io | bash -s stable
				- \curl -sSL https://get.rvm.io | bash -s stable --rails
		- Hm...this tried to install Homebrew, which promptly failed.
		- But it did suggest using a binary version of Ruby.
		- Damn...I need to install homebrew.  There doesn’t seem to be any way around this.
		- So, I installed Homebrew (https://brew.sh)
		- That seemed simple enough.
		- Next, I had to install Ruby, which is a simple `brew install ruby`
		- I updated my path.
		- It also said that for compilers to find ruby you may need to set:
			  export LDFLAGS="-L/opt/homebrew/opt/ruby/lib"
			  export CPPFLAGS="-I/opt/homebrew/opt/ruby/include"
		- I’ll add these to my `.zshrc` file if I need to.
		- I had to `source ~/.zshrc` to get the updated path to take effect, but then it worked -- `ruby -v` showed I was now running Ruby version 3.4.4.
		- Okay, so now I can try installing cocoapods again:
			- gem install cocoapods
		- That worked!
- Rosetta (needed for Apple Silicon):
		- sudo softwareupdate --install-rosetta --agree-to-license
		- That was straightforward
- Flutter
		- I downloaded Flutter for Mac OSX veresion 3.32.0 (stable).  This was another 2 gigabyte download.
		- I moved the `flutter` directory to ~/Development/flutter, as recommended.
- I then installed the Xcode command-line tools:
		- sudo sh -c 'xcode-select -s /Applications/Xcode.app/Contents/Developer && xcodebuild -runFirstLaunch'
- I then had to agree to Xcode’s license agreement:
		- sudo xcodebuild -license
- I then tested my Flutter installation with: `flutter doctor`
		- This found some issues with my path, which I fixed by changing from “development” to “Development”.
		- It also complained about lack of Android tools, but that’s okay for me.
		- It also said I didn’t have cocoapods installed, so I reinstalled these.
		- But it still couldn’t fidn them.
		- It also complained about a lack of installed simulator runtimes in Xcode -- is that important if I’m not building for iOS?
- I *think* flutter is installed correctly now.

## Building a Test App

- I next began working through the Flutter code lab (https://codelabs.developers.google.com/codelabs/flutter-codelab-first) to create a sample desktop app.
- I created the MapDesk/app directory.
- I added the `pubspec.yaml` file and filled it with the suggested contents, changing the app name to “MapDesk”
- I then created the `analysis_options.yaml` and added the suggested contents.
- Next I created the `lib/` directory, and the `main.dart` file within it.
- Hmmm...but the codelab assumes you’re installed the VS Code IDE.  I don’t want to do that and there’s no indication of how to do it without the IDE.
- I then tried the following:

```
% flutter devices
Found 2 connected devices:
  macOS (desktop) • macos  • darwin-arm64   • macOS 15.5 24F74 darwin-arm64
  Chrome (web)    • chrome • web-javascript • Google Chrome 136.0.7103.114
```

- So Flutter is configured for Mac OS desktop development.
- I finally found this: https://docs.flutter.dev/platform-integration/desktop
- So I deleted the files created via the code lab, and started again:

```
% cd ~/Library/CloudStorage/Dropbox/1.\ Projects/Agentic\ Coding/mapDesk
% flutter create map_desk
```

- Note that the app name needs to be lowercase with underscores.
- And now to test it:

```
% cd map_desk
flutter run
```

- And it worked!!!
- It’s also trivial to build a standalone Mac app:

```
% flutter build macos
```

- Nice!

Now I want to learn more about Flutter -- this is a good starting point: https://docs.flutter.dev/get-started/learn-flutter

###########################################

## Using in Cursor

I then opened the mapdesk folder in Cursor, and asked it:

```
analyse the map_desk app
```

It seemed to do a good job of this, figuring out it was a Flutter app and giving suggestions for how it could be extended.

It even read my work log file to see what I had done!

I then said “run the app”, and it did.

I then did:

```
when I say "run the app", automatically choose MacOS as the destination
```

And it did.  I can now just type “run” and the app runs.  Nice!

I then tweaked the app a bit more, removing the banner and setting up a basic “cursorrules” file to run the app in the right place.

I then removed the demo functionality, coming up with a very basic Flutter app that does nothing but show a window -- but it does run.

# Next Steps

I next need to setup a Git repository for this project, and commit the current app to it.

Here’s what I did:

- `cd` into the top-level directory for this project.
- Typed `git init` to initalise the repository.
- Added a `.gitignore` file to remove unwanted files.
- Added all existing files to the repository: `git add *`
- Committed the change: `git commit -m ‘Initial commit’`
- I then went to Github and signed in, creating a new repository there for the `map_desk` app.
- I then linked my local repository to GitHub using: `git remote add origin git@github.com:erikwestra/map_desk.git`
- Then I pushed my code using `git branch -M main` and `git push -u origin main`

Very nice -- Cursor had already set up a .gitignore in the source directory to exclude all temporary build files.  So all I have is the actual source to the app.

###############

I then looked at the source files, and realised I wanted to rename the topmost project directory from “map_desk” to “app”.  So I got Cursor to do this for me:

```
I want to rename the flutter project directory from 'map_desk' to 'app'
```

It renamed the directory, updated the .cursorrules file and rebuilt everything so that it works.

There was some leftover files in map_desk, but I asked Cursor why, and it removed them.

I also created empty `docs`, `explore` and `plan` directories.

