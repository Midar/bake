Bake
====

Bake is an easy way to build your projects. You just list all your targets,
sources, libraries and ingredients (packages are called ingredients in bake)
required to build your project in one central JSON5 file called Recipe and
bake will do the rest for you!

Dependencies
------------

All you need is the latest ObjFW from git. This will change as soon as there is
a new ObjFW release.

Structure of a Recipe
---------------------

Bake includes a Recipe to build itself which is well documented. Have look at
it!
As bake is still in it's early stages, there is currently no documentation. But
you can always use the source!

Ingredients
-----------

You can easily produce an ingredient using bake:
```
bake --produce-ingredient \
	-I/some/include/dir \
	-L/some/lib/dir \
	-lsomelib \
	> ingredients/something.ingredient
```

You can use the same way to easily convert a pkg-config package to an
Ingredient:
```
bake --produce-ingredient \
	`pkg-config --cflags --libs glib-2.0` \
	> ingredients/glib2.ingredient
```
