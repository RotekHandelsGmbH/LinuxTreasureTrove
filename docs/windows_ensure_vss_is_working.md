# Steps to Ensure that Shadow Copy Service (VSS) Is Enabled and Running

```bash
# Check the Volume Shadow Copy Service:
# Powershell as Admin : 
services.msc
# In the Services window, scroll down and locate Volume Shadow Copy.
# Right-click it and choose Properties.
# Set the Startup type to Manual or Automatic.
# Click Start if the service isn’t running, then click OK.

#Verify the Microsoft Software Shadow Copy Provider:
# In the same Services window, find Microsoft Software Shadow Copy Provider.
# Right-click it, select Properties, and set its Startup type to Manual or Automatic.
# Start the service if needed.

# Run DiskShadow from an Elevated Command Prompt:
# Powershell as Admin :
diskshadow

# If both services are running and you still encounter issues, make sure that your system’s environment variables 
# include the path to C:\Windows\System32 where DiskShadow resides. This should allow you to run DiskShadow without any further adjustments.
```
