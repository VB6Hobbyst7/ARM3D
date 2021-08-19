TFMXPlug: tfmx-play WinAMP Plugin v0.0.0.6

  by Per Linden <per@snakebite.com>
  using code developed by Jonathan H. Pickard <marxmarv@antigates.com>

COPYRIGHT AND LEGAL ISSUES
--------------------------

Player code Copyright 1996-1998 Jonathan H. Pickard.  All rights reserved.
WinAMP interface code etc. (based on tfmxplay Win32) (C) Per Linden 1998-

Redistribution and use in source and binary forms, with or without
modification, are permitted provided that the following conditions
are met:
1. Redistributions of source code must retain the above copyright
   notice, this list of conditions and the following disclaimer.
2. Redistributions in binary form must reproduce the above copyright
   notice, this list of conditions and the following disclaimer in the
   documentation and/or other materials provided with the distribution.
3. All advertising materials mentioning features or use of this software
   must display the following acknowledgement:

This product includes software developed by
Jonathan H. Pickard <marxmarv@antigates.com> and
Per Linden <per@snakebite.com>

4. The names of the author(s) may not be used to endorse or promote
   products derived from this software without specific prior
   written permission.

THIS SOFTWARE IS PROVIDED BY THE AUTHOR(S) ``AS IS'' AND ANY EXPRESS
OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
ARE DISCLAIMED.


GENERAL INFORMATION
-------------------
This is an input plugin for WinAMP for playing music modules in the TFMX
format, originally created for the Amiga by Chris Huelsbeck. It was written
by Per Lindén <per@snakebite.com>, based upon code by Jonathan H. Pickard.
For more information about the original program / source, see the link below.

Currently, you can find the latest version and other information about this
program at URL: http://listen.to/tfmx
(If this link has gone bad, do a search on TFMX and Win32, or something :-)


USAGE (for usage of previous versions, see the other readme file)
-----------------------------------------------------------------
Copy the file In_tfmx.dll to the "Plugins" subdirectory of WinAMP. If you
don't have such a directory, you probably have too old a version of WinAMP.
After that, WinAMP should be able to load and play TFMX modules. (*.tfx)

When playing a song, doubleclicking on the name shows the info window, which
contains some option checkboxes and a scrollbar to select subsong with.
The "kbps" box of the WinAMP window shows "7C" for a 7-voice module, and "4C"
for a 4-voice. (C means channels, if you didn't catch that... :-)


NOTES ON THE INTEGRATION TFMX <-> WINAMP
----------------------------------------
* The "MDAT." prefix of TFMX mods does not work very well in Win32 when it
  comes to wildcards, associating extensions, etc... The plugin still enables
  you to load MDAT.XXX files, although they do not show up in the
  "Play File...." requester, and can not (as far as I know) be associated
  with WinAMP. The easiest way is to rename all MDAT.xxx to xxx.TFX, and all
  SMPL.xxx to xxx.SAM.

* The "seek slider" of WinAMP is disabled. I consider the calculation of a
  TFMX module's length and any skipping into it an undecidable problem,
  since this format is almost Turing-complete... :-)

* The oscilloscope and spectrum analyzer aren't working very well. This is
  because that the mixing formulae of TFMXPlay results in a rather low output
  amplitude. I guess you could use the pre-amp slider of WinAMP to correct
  this.
  
* Some options of TFMXPlay are now available in a combined info/subsong
  selection dialog, brought out by doubleclicking on the song name.
  Please note that the dialog code is completely MFC-free! :-)


RECENT CHANGES
--------------

v0.0.0.4
--------
* Now accepts modules like Rock'n'roll, (with a "TFMX " magic
  number) but I can't guarantee that they are played completely right.
  If you can't stand the way it sounds, throw me a mail and I'll remove it...

* WinAMP Disk Writer should work better now. Fixed a stupid call made to the
  output module interface.

v0.0.0.5
--------
* Fixed a small but serious mistake that crashed WinAMP, especially version
  2.10. Thanks to those that reported this problem.

* Added some extra robustness code, just to be sure. Updated the DSP
  handling. If you have managed to use any WinAMP DSP plugins, please throw
  me a mail...

* By the way, I _am_ working on a version that saves the configuration
  settings in the registry. Please be patient...

v0.0.0.6
--------
* Fixed a major problem with WinAMP versions newer than 2.10 with the
  equalizer enabled, that caused the songs to play at double speed. The
  overall compatibility with WinAMP has now been improved. Thanks to everyone
  that has reported this problem.
  
* Because of changes in the way WinAMP works, the fix above now also makes the
  equalizer work properly, instead of doing nothing as in previous versions of
  WinAMP combined with TFMXPlug...

* Squashed a bug causing some voices to be turned off after playing 7 voice
  modules. Thanks to Stefan Schmitz for reporting this.

BUG REPORTS
-----------

Email bug reports, suggestions for improvement, errors in this text, anything,
etc. to <per@snakebite.com>

(Please note that I am no guru at the TFMX format itself. You can always ask,
but don't rely on me knowing everything... Some people just don't seem to 
understand this...)

[ Readme file v1.00 ] (Credits to John Eklund for some proofreading... ;-)


Signing off,
-- 
Per Linden, 13th of June, 1999
