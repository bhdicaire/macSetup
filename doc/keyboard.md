

# Command Shift
In order to change language input source in a more convenient way, i use `karabiner-elements` to remap keyboard shorcuts. Command + Shift is easy to use especially if you have a Windows background.
1. Go to Settings -> Keyboard -> Keyboard Shortcuts -> Input Sources and set a desired shorcut. I use `Cmd + E`
2. After karabiner-elements has been installed from the list of cask apps, open the terminal and cd to `~/.config/karabiner/assets/`
3. Once there, create a `.json` file that will handle the remapping. Example: [CmdShiftToCmdE.json](https://github.com/adreaskar/mac-setup/blob/master/misc/CmdShifttoCmdE.json)
4. This file creates a rule to map `Cmd + Shift` to `Cmd + E` thus changing input source.
5. After that, open karabiner-elements app and go to: Complex Modifications -> Rules -> Add rule and Enable Languages -> Command + Shift to Command + e.

https://github.com/adreaskar/mac-setup/blob/master/misc/CmdShifttoCmdE.json

CmdShifttoCmdE.json

{
  "title": "Languages",
  "rules": [
    {
      "description": "Command + Shift to Command + e",
      "manipulators": [
        {
          "type": "basic",
          "from": {
            "key_code": "left_shift",
            "modifiers": {
              "mandatory": [
                "left_command"
              ]
            }
          },
          "to": [
            {
              "key_code": "e",
              "modifiers": [
                "left_command"
              ]
            }
          ]
        }
      ]
    }
  ]
}
