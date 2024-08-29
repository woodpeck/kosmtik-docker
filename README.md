# Kosmtik in Docker

This repository provides scripts to use a [Kosmtik](https://github.com/kosmtik/kosmtik) instance
running in a Docker container for development of CartoCSS Mapnik styles on a Linux host.

Running the container requires a PostgreSQL running *on the host* and having a database with the
name used by the map style (often "gis"). The database is accessed via its Unix socket, the
directory of the socket is mounted in the container.

The map style directory is mounted in the container as well. It has to contain everything the
style requires (shapefiles etc.).

This readme does not explain how to set up a database and load OpenStreetMap data. Please
refer to other guide, e.g. switch2osm.org, for further information.

Build the Docker image (required only once):

```sh
./build_docker.sh
```

Start Kosmtik:

```
./start_kosmtik.sh -d /path/to/style/dir -m path_to_mml_relative_to_dir_arg.mml
```

The `-m` argument has to be a path relative to the argument of `-d`. It must not
point upwards in the directory tree.


## Dependencies

This container relies on some dependencies which have to be available on the host
system:

* PostgreSQL database with contents in the structure requied by the map style
* xmllint
* all fonts required by the style and not shipped with the style
* Bash

If Fontconfig is not installed on your system (e.g. OS X), call `start_kosmtik.sh`
with the `-n` option and provide the font directories using `--add-font-dir`.

## License

This project is published under WTFPL. See the LICENSE file for further information.
