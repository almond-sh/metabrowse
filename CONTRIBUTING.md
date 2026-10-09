# Contributing

Tickets and patches are very welcome!

Metabrowse follows [scalameta's contribution guidelines]. Please read them for
information about how to create good bug reports and submit pull requests.

For ideas of how to contribute, take a look at the list of tickets with the
[<kbd>help wanted</kbd> label][help-wanted].

 [help-wanted]: https://github.com/scalameta/metabrowse/issues?q=is%3Aissue+is%3Aopen+label%3A%22help+wanted%22
 [scalameta's contribution guidelines]: https://github.com/scalameta/scalameta/blob/master/CONTRIBUTING.md

Remember to run

```
./bin/scalafmt
```

Before raising a PR to ensure the code is formatted correctly (otherwise it will fail the checks)

## Running locally

To run metabrowse on corpus locally,

```
git clone https://github.com/scalameta/metabrowse.git
cd metabrowse
git submodule init
git submodule update

npm install -g yarn

./mill jsBundle.devServer             # generate static site for paiges, spin up local file server that listens for changes.
./mill -w 'js[2.13.16].fastLinkJS'    # in another terminal: compiles Scala.js application, browser refreshes on edit.
open http://localhost:8080
```

To only generate the static site, run `./mill show 'example[2.13.16].metabrowseSite'`, which prints the
directory it's written to.

## Running tests

```
./mill 'tests[2.13.16].test'    # JVM tests
./mill 'js[2.13.16].test'       # Scala.js tests
```

## Packaging CLI Locally

```
./mill show 'cli[2.13.16].assembly'   # prints the path of the generated JAR
java -jar out/cli/2.13.16/assembly.dest/out.jar ...
```

## Upgrading the Monaco Editor

Metabrowse interfaces with the Monaco Editor using a Scala.js facade based on the
`monaco.d.ts` TypeScript type definition file provided as part of the
`monaco-editor` NPM package. The facade can be generated with
[scala-js-ts-importer], however, manual merging is necessary, since the facade
contains several custom tweaks.

The following instructions give a rough idea how to upgrade the monaco editor
facades:

 - Update the Monaco Editor version in `metabrowse-js/package.json` and
   `metabrowse-js/yarn.lock`
   ```
   $ cd metabrowse-js && yarn upgrade monaco-editor@x.y.z
   ```
 - Run script to update the `Monaco.scala` file
   ```
   $ bin/update-monaco-facade.sh
   ```
   This might require tweaking the curated list of edits (the `sed` command in
   the script.
 - Fix the `package importedjs {}` code inserted by [scala-js-ts-importer] by
   manually editing `Monaco.scala`
 - Reformat `Monaco.scala`
   ```
   $ bin/scalafmt metabrowse-js/src/main/scala/monaco/Monaco.scala
   ```

At this point merge the changes to `Monaco.scala` using `git add -i` or some
other tool, like `tig`. Stage any newly introduced types or methods and revert
changes that remove tweaks, such as use of `override` in front of `clone` and
`toString` methods.

 [scala-js-ts-importer]: https://github.com/sjrd/scala-js-ts-importer
