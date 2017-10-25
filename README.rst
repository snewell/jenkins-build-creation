jenkins-build-automation
========================
This is a collecction scripts to automate the creation of jobs in a Jenkins_
server.  The scripts and provided configurations are designed to meet my
needs, but they should be close to what most projects that use CMake_ could
use.

All builds use my `workflow library`_.  For installation instructions, please
see that repository.


Usage
-----
Scripts include usage information if run without arguments.  Select the
appropriate script and execute it with the required arguments.  For scripts
that require an authentication token, you can either use a username and
password or a username and API token.  The API token is *strongly*
recommended, and a new one should be generated immediately after job creation
is complete (this prevents any active token from sticking around in your
:code:`.bash_history`).

If you're on a typical Unix-like system you should be fine; the scripts assume
a typical suite of CLI tools, including :code:`find`, :code:`curl`,
:code:`sed`, :code:`cut`, and :code:`basename`.  They assume you have
everything required in :code:`PATH`.

Example:

.. code:: bash

    # username: snewell
    # API token: b211f7531eb3a674753a28b54ca3369d
    sh create_all_builds.sh http://localhost:8080 snewell \
       b211f7531eb3a674753a28b54ca3369d bureaucracy-builds \
       https://github.com/snewell/bureaucracy/ master`


Build Customization
-------------------
The scripts and configurations in this project are expected to be modified by
anybody who's using them; they probably won't be exactly what you need by
default.  Rather than trying to support every possible build configuration, I
assume you'll use them as a template for your own requirements.

Job configurations are stored using XML files, and the ones provided are
copied directly from my personal jobs (removing things like branch names and
paths to the git repo).  If you need more customization (extra arguments,
compiler paths, different build dependencies, etc.) the easiest solution is
probably to configure the job the way you want it, then replace the files in
the :code:`build-configs` directory.


.. _CMake: https://cmake.org/
.. _Jenkins: https://jenkins.io/
.. _workflow library: https://github.com/snewell/jenkins-workflow
