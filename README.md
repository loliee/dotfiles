# ~/.dotfiles

## Install

### Installation

Using [GNU Stow](http://www.gnu.org/software/stow/):

```bash
git clone https://github.com/loliee/dotfiles ~/.dotfiles
cd ~/.dotfiles
make install
```

### Uninstallation

```bash
cd ~/.dotfiles
make uninstall
```

## Mac setup

Install [Xcode](https://itunes.apple.com/fr/app/xcode/id497799835?mt=12) first.

### Sensible OS X defaults

When setting up a new Mac, you may want to set some sensible OS X defaults:

```bash
./.osx
```

### Install Homebrew Formulae/Native apps

```bash
./.brew 2>/dev/null
```

### Install Vim Plugins

```bash
vim +PluginInstall +qall
```

### Ressources

[Official manual page](https://developer.apple.com/library/mac/documentation/Darwin/Reference/ManPages/man1/defaults.1.html).

**List defaults**

```bash
rc="\n" && defaults domains | sed s/,/"$rc"/g
```

**Read default values**

```bash
defaults read com.apple.mail
{
   AddressesIncludeNameOnPasteboard = 0;
   BundleCompatibilityVersion = 3;
   DisableInlineAttachmentViewing = 1;
   DisableReplyAnimations = 1;
   DisableSendAnimations = 1;
   DraftsViewerAttributes =     {
       DisplayInThreadedMode = yes;
       SortOrder = "received-date";
       SortedDescending = yes;
   };
   EnableBundles = 1;
   NSUserKeyEquivalents =     {
       Send = "@\\\\U21a9";
   };
   SpellCheckingBehavior = NoSpellCheckingEnabled;
}
```

## Todo

  - OSX remap caplocks to ctrl
  - Setup divvy
  - Setup avatar correctly
  - Check active corner
  - Setup istat menu and info bar
  - Disable guest account
