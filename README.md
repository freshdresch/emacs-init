
# My emacs `init.el`
Plenty of other good ones to pull from online, but they often are overwhelming in scope (both configuration and plugins). This is the bare minimum I want on a new machine. All packages are installed through [MELPA](https://github.com/melpa/melpa), so that is a prequisite for everything else. The package `use-package` is also necessary after `MELPA` is installed.

## Required packages 
These are required for the `init.el` file to work as-is. Of course undesired packages could be commented out of the `init.el` and not installed.

* Modern C++ syntax highlighting: `modern-cpp-font-lock`
* Google's C++ style: `google-c-style`
* clang format support: `clang-format`
* Parentheses highlighed by color gradient: `rainbow-delimeters`
* Smart code indenting that helps format multiline statements properly: `smart-tab`
* Programming language major modes: 
  * Rust: `rust-mode`
  * Nim: `nim-mode`
  * Dlang: `d-mode`
  * Go: `go-mode`
* Better experience opening very large files: `vlf`
* Highlighting tabs: `whitespace`
* Themes:
  * [Spolsky](https://github.com/bbatsov/solarized-emacs), my GUI theme: `solarized-theme`
  * [Monokai Pro](https://github.com/oneKelvinSmith/monokai-emacs), my terminal theme: `monokai-pro-theme`

