SAL-build-scripts
===================
**Build scripts for the Uni. Southampton Astronomy Dept. Lofar cluster**
(Hence, S.A.L. build scripts)


A collection of scripts for building various radio astronomy software packages,
including `casacore/casarest/pyrap`, the LOFAR imaging pipeline, and the LOFAR-TKP
transients detection pipeline. 

Linux build system engineers might also find some useful snippets here,
since it employs some slightly circuitous bash scripts to effect continuous
deployment practices, despite the packages being built from a rag-tag collection 
of C++ and python. While slightly hacky, this is a very lightweight and 
dependency-free alternative to say, creating a virtual machine for each build.

Notes
---------
The most generally applicable routines are contained in ``utils.sh``, including snippets for 
forcing fresh checkouts of git repositories, and grabbing their id hashes.

Many of the scripts are simply convenience routines for downloading and building packages with a single 
command (the ``grab_install_X`` routines). These make use the master variables set in ``CONFIG`` to 
determine the install target.

Scripts named in CAPS are generally more complex, doing things like updating
repositories and then building to target folders named using the svn/git hashes.

Using versioned builds in turn allows for 'continuous deployment' practices, wherein the latest of
each the package builds is collected together to create a 'buildset' - this is done
by collecting symlinks pointing to particular builds into one master set 
of bin/lib/pythonpath directories, archived via the date and time at which the 
set was collected. These master directories can then be added to the environment 
variables to make use of a given buildset. To make this a non-intrusive process
for end-users, we manually update a symlink to the current desired buildset, 
and end-users simply run an environment setup script sourced via that symlink.
This also allows multiple buildsets to be used concurrently, for purposes of
testing, stability and backwards compatibility - simply set the environment variable 
(e.g. ``SAL_STABLE_BUILDSET``) pointing to the desired buildset before sourcing the 
init script that adds the relevant directories to the environment path variables.

The symlinking process is a bit arcane, but has been refined to resolve 
intermediate symlinks to ensure that once a buildset has been defined,
it will **stay fixed** and working unless the original build folders are deleted.
A pleasant side effect is that the symlinked programs in a buildset are never 
too many layers of symlinks from their final path entry; 
one can determine the exact build of a program in use via the command::

  readlink $(which <someprogram>)

You can find the code that collects and resolves symlinks in ``collate_stable_software_symlinks.sh``.

Note that python packages that prefer installation via a .pth file (e.g., `pyrap`) don't fit
well in this system, as a .pth file cannot simply be added to the PYTHONPATH. Fortunately,
it's pretty simple to script the unpacking of a .pth file to a regular python package folder,
at least in this case. See ``utils.sh`` for the relevant bash snippet.

See ``CONFIG`` for the master variables defining where repositories / tarballs are 
downloaded to, and where builds are installed to.

See ``DEPLOY_README.sh`` for a typical command sequence when installing from scratch on a fresh Ubuntu 12.04 system.

To Do
-------------

  - DEPLOY_README.sh needs updating.
