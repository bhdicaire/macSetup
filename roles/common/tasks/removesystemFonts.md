A large number of the fonts (particularly in the root /Library/Fonts/ folder) are there for foreign language support.
One version of the OS they're in the System folder, and the next the same required font is in the Library folder.

Source: Font Management in macOS and OS X, by Kurt Lang // Last updated July 9, 2017
http://www.jklstudios.com/misc/osxfonts.html


Font Book

Pros:

1) It's free.
2) Can create font sets.
3) Resolves font conflicts. Much better control in Lion through Sierra than previous versions.
4) Can deactivate fonts in the /Library/Fonts/ and ~/Library/Fonts/ folders to prevent any application from seeing them.
5) Can create Library sets to open fonts in place.
6) Has an automatic activation feature.

Cons:

1) Different library sets can contain the same fonts, but they must be linked from exactly the same location in order to activate them.
2) Resolving fonts always favors those in the /System/Library/Fonts/ folder. This makes it impossible to activate another type of font with the same name without having to first manually remove the conflicting font in the System folder.
3) The conflict resolution function, whether using automatic or manual, can and will remove fonts from the main Library folder. Handling of this issue is much improved in Yosemite and later.

I would recommend you remove all but the most basic fonts listed in section one to get your system down to only the fonts it needs in the /System/Library/Fonts/ folder. It's up to you then whether or not you want to empty out the /Library/Fonts/ and ~/Library/Fonts/ folders since they can be controlled from within Suitcase Fusion 7.

/System/Library/Fonts/ folder:

Apple Color Emoji.ttc
Avenir.ttc
Courier.dfont
Geneva.dfont
Helvetica.dfont
HelveticaNeue.dfont
HelveticaNeueDeskInterface.ttc
Keyboard.ttf
LastResort.ttf
LucidaGrande.ttc
Menlo.ttc
Monaco.dfont
PingFang.ttc
SFCompactDisplay-Black.otf
SFCompactDisplay-Bold.otf
SFCompactDisplay-Heavy.otf
SFCompactDisplay-Light.otf
SFCompactDisplay-Medium.otf
SFCompactDisplay-Regular.otf
SFCompactDisplay-Semibold.otf
SFCompactDisplay-Thin.otf
SFCompactDisplay-Ultralight.otf
SFCompactRounded-Black.otf
SFCompactRounded-Bold.otf
SFCompactRounded-Heavy.otf
SFCompactRounded-Light.otf
SFCompactRounded-Medium.otf
SFCompactRounded-Regular.otf
SFCompactRounded-Semibold.otf
SFCompactRounded-Thin.otf
SFCompactRounded-Ultralight.otf
SFCompactText-Bold.otf
SFCompactText-BoldItalic.otf
SFCompactText-Heavy.otf
SFCompactText-HeavyItalic.otf
SFCompactText-Light.otf
SFCompactText-LightItalic.otf
SFCompactText-Medium.otf
SFCompactText-MediumItalic.otf
SFCompactText-Regular.otf
SFCompactText-RegularItalic.otf
SFCompactText-Semibold.otf
SFCompactText-SemiboldItalic.otf
SFNSDisplay.ttf
SFNSDisplayCondensed-Black.otf
SFNSDisplayCondensed-Bold.otf
SFNSDisplayCondensed-Heavy.otf
SFNSDisplayCondensed-Light.otf
SFNSDisplayCondensed-Medium.otf
SFNSDisplayCondensed-Regular.otf
SFNSDisplayCondensed-Semibold.otf
SFNSDisplayCondensed-Thin.otf
SFNSDisplayCondensed-Ultralight.otf
SFNSText.ttf
SFNSTextCondensed-Bold.otf
SFNSTextCondensed-Heavy.otf
SFNSTextCondensed-Light.otf
SFNSTextCondensed-Medium.otf
SFNSTextCondensed-Regular.otf
SFNSTextCondensed-Semibold.otf
SFNSTextItalic.ttf
Symbol.ttf
Times.dfont
ZapfDingbats.ttf (optional)

/Library/Fonts/ folder:

AppleGothic.ttf
Arial Black.ttf
Arial Bold Italic.ttf
Arial Bold.ttf
Arial Italic.ttf
Arial Narrow Bold Italic.ttf
Arial Narrow Bold.ttf
Arial Narrow Italic.ttf
Arial Narrow.ttf
Arial Rounded Bold.ttf
Arial.ttf
Comic Sans MS Bold.ttf
Comic Sans MS.ttf
Georgia Bold Italic.ttf
Georgia Bold.ttf
Georgia Italic.ttf
Georgia.ttf
Impact.ttf
Tahoma Bold.ttf
Tahoma.ttf
Times New Roman Bold Italic.ttf
Times New Roman Bold.ttf
Times New Roman Italic.ttf
Times New Roman.ttf
Trebuchet MS Bold Italic.ttf
Trebuchet MS Bold.ttf
Trebuchet MS Italic.ttf
Trebuchet MS.ttf
Verdana Bold Italic.ttf
Verdana Bold.ttf
Verdana Italic.ttf
Verdana.ttf
Webdings.ttf
Wingdings 2.ttf
Wingdings 3.ttf
Wingdings.ttf

 I simply want each face to properly reference the same family. Everything works as is, but rather than 1 menu item with the family name, then a sub menu for all the faces, I have 1 menu item for each face even though they are the same family.

Font Management applications do not reconfigure internal font data.
The problem I have is each face is listed separately in various applications (Photoshop, Indesign, etc.) Rather than simply one item with a submenu for faces.
https://www.new.fontlab.com/font-converter/transtype/
http://robofont.com/
For example I have:
(fig. A)

FontA Bold >
           Regular
FontA Bold Italic >
           Regular
FontA Italic >
           Regular
FontA Regular >
           Regular
Rather than:
(fig. B)

FontA >
        Bold
        Bold Italic
        Italic
        Regular

###rename using fontForge

####Edit the Font

Open the file and goto Element > Font Info.
Under PS Names, change the Font Family to the common name you want. Leave Fontname and Name For Humans alone.
Under TTF Names you can change the String for String ID "Styles (SubFamily)" to a unique name for that specific font like "Book-Italic"
Select "Preferred Family" and click the delete button.
Select "Preferred Style" and click the delete button.
Click OK
#### Save the File

Select File > Generate Fonts
Change The select box under the font name to OpenType (CFF)
Click Save
Ignore Errors and Save
####Test

Close out of Font Book and then open the file and it should have the common font name in the title and the unique name in the drop-down.

----
# delete unused fonts
Make backup copies of all System and Library fonts, first.

Boot to the Recovery partition and turn off System Integrity Protection. In Recovery mode, launch Terminal from the menu bar. Then enter:

csrutil disable

You should get a return message that SIP has been disabled. Then enter:

reboot

The Mac will restart. Once back at the normal desktop, you'll be able to put any fonts in the trash you want to get rid of and empty the trash.

Return to Recovery mode and repeat as above, except turn SIP back on by entering:

csrutil enable
