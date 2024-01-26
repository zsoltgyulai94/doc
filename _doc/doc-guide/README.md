---
title: Documentation Guide
---

[ref:mm-javascripts]: https://mmistakes.github.io/minimal-mistakes/docs/javascript/
[ref:mm-js-update]: https://mmistakes.github.io/minimal-mistakes/docs/javascript/#build-process
[ref:ruby-and-gems-install]: https://jekyllrb.com/docs/installation/

## Structure of this repository

## Tools you need for local testing your documentation changes

1. [Install Ruby and RubyGems][ref:ruby-and-gems-install]
2. Install bundler\
   It's just a ruby gem itself too, so siply run `gem install bundle`
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
    ./_tools/navgen ./_doc ./_data/navigation.yml
    ```

    Note: This will update the `navigation.yml` file based on the content of the `_doc` folder wehre all of our doumentation markdown files are located.
      Note: Automation of this is in progress, the `serve` tool will take care of this as well in the future, also it will be part of the GitHub deplyment flow
      {: .notice}
3. Sometimes its neded to [update][ref:mm-javascripts] the internally used `minimal-mistakes` theme default [.js scripts][ref:mm-js-update]
    You can use our still in a work progress, but usable helper tool.
    After updated the .js files you have to in `${PROJECT_ROOT}/assets/js/` you can simply run

    ```shell
    ./_tools/pack
    ```

    It will update the `${PROJECT_ROOT}/assets/js/main.min.js` file that will be built and deployed normally in the next dev cycle.

    Warning: There are multiple issues we cannot deal with yet, and are postponed for later. You can find some info about them in the script file, please feel free to contribute if you have a solution.
    {: .notice--danger}
