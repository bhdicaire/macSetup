# Shell Prompt
Install the shell prompt of choice as shown in [SHELL-PROMPTS.md](https://github.com/adreaskar/mac-setup/blob/master/pages/SHELL-PROMPTS.md)

# Apps
Install all the listed apps in the [brew-casks.txt](https://github.com/adreaskar/mac-setup/blob/master/brew-casks.txt) file  with the command:
```
xargs brew install < brew-casks.txt
```


# Oh My Zsh
To install Oh My Zsh run:
```
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
```
Docs: [Oh My Zsh documentation](https://github.com/ohmyzsh/ohmyzsh/wiki)

## PowerLevel10K Theme for Oh My Zsh
To install PowerLevel10K theme run:
```
git clone https://github.com/romkatv/powerlevel10k.git $ZSH_CUSTOM/themes/powerlevel10k
```
Now that it's installed, open the "~/.zshrc" file and change the value of "ZSH_THEME" as shown below:
```
ZSH_THEME="powerlevel10k/powerlevel10k"
```

## ZSH Plugins

1) Install zsh-autosuggestions:
```
git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
```
2) Install zsh-syntax-highlighting:
```
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting
```
Open the "~/.zshrc" file and modify the plugins line to the following:
```
plugins=(git zsh-autosuggestions zsh-syntax-highlighting web-search)
```


 hidden files and folders visible in Finder

 chflags nohidden <files>

 So you are able to look:
1) Open Terminal
2) cd ~/Desktop
3) find . -exec ls -lO {} \;|grep hidden
If you have such files you are able to clear this flag for all files in the tree by command:
4) chflags -R nohidden *
or for file:
4*) chflags nohidden file.txt

FYI If your file has attribute mask -rw------ - it's not standart, so i'm able to change it by the command:
chmod -R a+r *
So the mask will be -rw-r--r--


pkgutil --files com.apple.pkg.RosettaUpdateAuto
