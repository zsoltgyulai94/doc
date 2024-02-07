---
title: Documentation Guide
---

[ref:mm-javascripts]: https://mmistakes.github.io/minimal-mistakes/docs/javascript/
[ref:mm-js-update]: https://mmistakes.github.io/minimal-mistakes/docs/javascript/#build-process
[ref:mm-dir-struct]: https://mmistakes.github.io/minimal-mistakes/docs/structure/
[ref:mm-dependencies]: https//jekyllrb.com/docs/configuration/
[ref:jekyll-dir-struct]: https://jekyllrb.com/docs/structure/
[ref:jekyll-config]: https//jekyllrb.com/docs/configuration/
[ref:ruby-and-gems-install]: https://jekyllrb.com/docs/installation/
[gh:doc-project]: https://github.com/syslog-ng/doc

## Structure of this repository

Basically we follow [jekyll][ref:jekyll-dir-struct] and [minimal-mistake][ref:mm-dir-struct]

```shell
.
├── _data
├── _includes
│   ├── footer
│   ├── head
│   ...
│   └── search
├── _layouts
├── _sass
│   └── minimal-mistakes
├── _site
├── _tools
├── assets
│   ├── css
│   ├── images
│   └── js
│       ├── custom
│       ├── plugins
│       ...
│       └── vendor
├── doc
│   ├── _admin-guide
│   ├── _dev-guide
│   └── _doc-guide
```

### Directories

- _data \

- _includes \

- _layouts \

- _sass \

- _site \

- _tools \

- assets \
  - js \
    - custom \
      To stay organized, please keep our custom scripts in the `js/custom` folder. \

- doc \

### Files

- _config.yml \
    [Jekyll configuration][ref:jekyll-config] file
- Gemfile \
    [Jekyll and minimal-mistake][ref:mm-dependencies] Ruby gem dependencies
- README.md \
    The porject [GitHub repository][gh:doc-project] landing page readme file
- LICENSE.* \
    All the licence files of the modules the porject uses

## Tools you need for local testing your documentation changes

1. [Install Ruby and RubyGems][ref:ruby-and-gems-install]
2. Install bundler\
   It's just a ruby gem itself too, so simply run `gem install bundle`
3. [Install node.js][ref:mm-javascripts]

## Our helper tools for local development and testing

We have a few useful tools in the `${PROJECT_ROOT}/_tools` folder some of them will be mentioned here, please see the content for more, or add your usefull ones if you wish.

1. The most useful tool is `jekyll serve`, you can start it like `bundle exec jekyll serve`, but we have a sript for it you can start like the original serve, assuming you are in the `${PROJECT_ROOT}/_tools` folder

    ```shell
    ./_tools/serve --host=127.0.0.1 --port=4000 --livereload-port=30000 -l -w --trace
    ```

    This will,
    - live refresh the site pages which are opened in a browser page
    - it can handle '_config.yml' changes as well that is not supported by jekyll at the moment

      Note: Unlike `--liverolad`, this will restart `jekyll serve` and not refreshing the opened web pages, so you have to refresh the opend pages
      {: .notice}
2. Generating the left sidebar navigator content is semi-automatic yet, its content is generated from the `${PROJECT_ROOT}/_data/navigation.yml` file, it will be readed by jekyll automatically during the site build process, but adding the correct content of it is our responsibility. Fortunately we have already a helper to simplify this, you can call it from the `${PROJECT_ROOT}` like

    ```shell
    ./_tools/navgen ./doc ./_data/navigation.yml
    ```

    This will update the `navigation.yml` file based on the content of the `_doc` folder wehre all of our doumentation markdown files are located.
    The tools is part of the GitHub deployment workflow as well, this is the reason why we have `${PROJECT_ROOT}/_data/navigation.yml` file is excluded via ``.gitignore`

    Note: Automation of this during development is in progress, the `serve` tool will take care of this as well in the future.
    This tools is part of the GitHub deployment workflow too, this is the reason why we have `${PROJECT_ROOT}/_data/navigation.yml` file is excluded via ``.gitignore`
    {: .notice}
3. Sometimes its neded to [update][ref:mm-javascripts] the internally used `minimal-mistakes` theme default [.js scripts][ref:mm-js-update] \
    If you modify any of the scripts packed into the `${PROJECT_ROOT}/assets/js/main.min.js` file, you have to [re-pack][ref:mm-js-update] it.
    You can use our, still in a work progress, but usable helper tool.
    After updated the given dependency .js file you can simply run

    ```shell
    ./_tools/pack
    ```

    It will update the `${PROJECT_ROOT}/assets/js/main.min.js` file that will be built and deployed normally in the next dev cycle.
    This tools is also part of the GitHub deployment workflow, so the `${PROJECT_ROOT}/assets/js/main.min.js` file is excluded via ``.gitignore`

    Important: Except the ones in the `js/custom` folder,  all the files in the `js` folder are presented here to get the re-packing work. \
    Packing all the requirements that really needed is not supported yet, please see the warning bellow.
    So, only these default files will be packed at the moment, this is the inherited defult of `minimal-mistake`, if you have to modify these please try to minimize the further dependencies otherwise the packing might not work.
    {: .notice--info}

    Warning: There are multiple issues we cannot deal with yet during re-packing and those are postponed for later examination. You can find some info about this in the script file, please feel free to contribute if you have a solution.
    {: .notice--danger}
