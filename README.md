# FSKit Sample

FSKit is the new framework introduced in macOS Sequoia 15.4 that enables the developer to provide custom filesystem support from user space. The document is almost non-existent at the moment so here is a sample project to show how to use the framework.

`UnaryFilesystemExtension` is the entry point of your custom filesystem. The implementation should return an instance of your custom filesystem implementation.

The filesystem should be a subclass of `FSUnaryFileSystem` and conforms to necessary protocols, specifically `FSUnaryFileSystemOperations` as the system invokes that when deciding if the custom FS should be used, and get the volume from the extension.

From there, you can create your own subclass of `FSVolume` to help manage your volume and conform to `FSVolume.Operations` to support the basic volume specific operations. For a fully functional volume implementation, you’ll probably need to conform to most of the `FSVolume.*Operations`.

Once you build and run the app, enable the File System extension under `System Settings -> General -> Login Items & Extensions -> File System Extensions`. After that you should be able to mount the FS with something like these (`disk18` is a block device)

```
mkdir /tmp/TestVol
mount -F -t MyFS disk18 /tmp/TestVol
```

And unmount them with

```
umount /tmp/TestVol
```

To create a dummy block device to test this, you can do the following

```
mkfile -n 100m dummy // create a dummy file
hdiutil attach -imagekey diskimage-class=CRawDiskImage -nomount dummy // mount the newly created file as a raw block device
```

and then use it with your FS.
