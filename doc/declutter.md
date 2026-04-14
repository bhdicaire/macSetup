# user's home directory conventions

Using directories defined by well-known conventions keeps the `~` folder clean and makes migrating between machines and operating systems much simpler.

Homebrew acts as a "package manager," automating the installation of CLI tools and GUI apps (via Casks) into these specific paths to simplify system maintenance [1, 3].

**What to put where:**

1.  **`~/.config` (XDG_CONFIG_HOME):** Use this for **configuration files**. This is where you should store settings for tools like git, shell aliases, or text editors [[2](https://stackoverflow.com/questions/3373948/equivalents-of-xdg-config-home-and-xdg-data-home-on-mac-os-x), [6](https://specifications.freedesktop.org/basedir/latest/)].
2.  **`~/.local/share` (XDG_DATA_HOME):** Use this for **persistent data files**, such as application state, local databases, or small icons/fonts [[2](https://stackoverflow.com/questions/3373948/equivalents-of-xdg-config-home-and-xdg-data-home-on-mac-os-x), [6](https://specifications.freedesktop.org/basedir/latest/)].
3.  **`~/.local/bin`:** Though not strictly part of the base spec, it is commonly used to store **user-specific executable binaries** that aren't managed by the system package manager [[3](https://aliquote.org/post/xdg-specs-on-macos/)].
/opt/homebrew
/Applications & ~/Applications

/opt/homebrew: This is the default prefix for Homebrew on Apple Silicon. It was chosen to prevent conflicts with Intel-based installations (Rosetta 2), which use /usr/local [5]. This separation allows both native ARM and translated x86 binaries to coexist safely on the same system [5].

/Applications: This is the system-wide directory for applications available to all users. On Apple Silicon, this includes native apps optimized for M-series chips and iPhone/iPad apps downloaded via the Mac App Store [2, 4].

~/Applications: Located in the user’s home folder, this directory is for apps installed only for a specific user. It does not require administrative privileges for installation, providing a layer of security and personalization.

[[3](https://aliquote.org/post/xdg-specs-on-macos/), [4](https://www.reddit.com/r/golang/comments/1pgsy08/xdg_base_directory_specification_use_avoid_or_it/)].

## 🌐 Sources

1. [github.com - Respect XDG Base Directory specification on macOS #475](https://github.com/charmbracelet/glow/issues/475)
2. [stackoverflow.com - macos - Equivalents of XDG_CONFIG_HOME and ...](https://stackoverflow.com/questions/3373948/equivalents-of-xdg-config-home-and-xdg-data-home-on-mac-os-x)
3. [aliquote.org - XDG Base Directory and macOS](https://aliquote.org/post/xdg-specs-on-macos/)
4. [reddit.com - XDG Base Directory Specification - use, avoid or it is the ...](https://www.reddit.com/r/golang/comments/1pgsy08/xdg_base_directory_specification_use_avoid_or_it/)
5. [news.ycombinator.com - And yet you impose XDG (originally a GNOME ...](https://news.ycombinator.com/item?id=37155857)
6. [specifications.freedesktop.org - XDG Base Directory Specification](https://specifications.freedesktop.org/basedir/latest/)

The rationale for using .config and .local on macOS is to adhere to the XDG Base Directory Specification, a standard originating from Unix-like desktop environments (like GNOME) to declutter the user's home directory [5, 6]. While macOS has its own native conventions (e.g., ~/Library/Application Support), many cross-platform developer tools and CLI programs default to XDG paths to maintain consistency across operating systems [1, 3].

he rationale for using .config and .local on macOS is to adhere to the XDG Base Directory Specification, a standard originating from Unix-like desktop environments (like GNOME) to declutter the user's home directory


# What are the rationale for the .config and .local directories in a macOS account what should I put where

## 🗒️ Answer

The rationale for using `.config` and `.local` on macOS is to adhere to the **XDG Base Directory Specification**, a standard originating from Unix-like desktop environments (like GNOME) to declutter the user's home directory [[5](https://news.ycombinator.com/item?id=37155857), [6](https://specifications.freedesktop.org/basedir/latest/)]. While macOS has its own native conventions (e.g., `~/Library/Application Support`), many cross-platform developer tools and CLI programs default to XDG paths to maintain consistency across operating systems [[1](https://github.com/charmbracelet/glow/issues/475), [3](https://aliquote.org/post/xdg-specs-on-macos/)].