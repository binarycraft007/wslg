## WSLg Manager - A Tool for Managing Wayland Symlinks in WSL

This program is a command-line tool for managing symbolic links related to Wayland in a Windows Subsystem for Linux (WSLg) environment. It allows you to start or stop Wayland by creating or removing specific symlinks.

**Features:**

* Creates symlinks for Wayland connections between WSL and the host system (Windows).
* Removes symlinks to stop Wayland.
* Provides basic error handling and logging for troubleshooting.

**Usage:**

```
wslg <operation> <UID>
```

* `<operation>`: Specifies the action to perform.
    * `start`: Creates symlinks to initiate Wayland.
    * `stop`: Removes symlinks to terminate Wayland.
* `<UID>`: The user ID (UID) of the WSL user account for whom the symlinks are being managed.

**Example:**

```
./wslg start 1000
```

This command starts Wayland for the WSL user with UID 1000.

**Implementation Details:**

* The program utilizes the `std` library for various functionalities like memory management, file system access, and debugging.
* It defines custom structures like `Path` and `SymlinkMap` to represent file paths and symlink information.
* The `isAccessOk` function checks if a file path is accessible (exists).
* The `wslgStart` and `wslgStop` functions handle symlink creation and removal based on the provided operation and UID.
* The `usage` function displays usage instructions and exits the program if incorrect arguments are provided.

**Important Notes:**

* Ensure you have appropriate permissions to manage symlinks in the specified locations.
* The provided symlink configuration (`symlinkMap`) might need adjustments depending on your specific WSL setup.

**Further Development:**

* Implement more robust error handling and logging mechanisms.
* Add support for additional symlink configurations.
* Consider options for user-defined symlink locations.

I hope this README provides a comprehensive overview of the WSLg Manager program. If you have any further questions or require assistance with customization, feel free to consult the source code for details.
