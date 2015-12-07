AsyncBeep 1.0
=============

This component wraps the Windows API beep function so that it can be used asynchronously.



Installation
============
To install the component with the Delphi IDE:

  1. Click "Component/Install...".
  2. Select a package to install the component to.
     Please note: this must be a designtime package.
  3. Recompile the package. The component should now appear on the "Freeware" tab.
   
   
   
Usage
=====
Drop the component on your form. Whenever you need a beep, call the component's 
DoBeep method passing the pitch in Hertz and the duration in milliseconds. 
Please note that the parameters only have an effect on Windows NT/2000. 
Windows 95/98 (and maybe also ME?) ignore these parameters.
  


License
-------
The component ist licensed under the MIT License. For details,
please refer to the LICENSE file.
