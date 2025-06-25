---
title: About this Document
layout: home
parent: Home
nav_order: 1.1
---

### About this Document

To contribute to this documentation, please visit [Github Pitrac](https://github.com/jamespilgrim/PiTrac)

To quickly test your documentation locally, please take the following steps: 

- Become familiar with `just-the-docs` project [just-the-docs](https://github.com/just-the-docs/just-the-docs)
    1. Install Ruby with [Ruby Installer](https://rubyinstaller.org/)
    2. Install jekyll and bundler `gem install jekyll bundler` 
    3. Install required libraries `bundler install`
    4. Serve the page `bundle exec jekyll serve --livereload`
    5. Visit the local page `http://localhost:4000`

- Run locally, which is also documented in the above point: `bundle exec jekyll serve.` Of course I am simplifying as you need to install [bundler](https://bundler.io/guides/getting_started.html). You also need to install and configure [jekyll](https://jekyllrb.com/tutorials/using-jekyll-with-bundler/)

- View how this project inside `docs` is configured to get an understanding of the documentation pattern. 

- Finally to deploy. Create your peer-review (PR) request. Github Action workflows will automatically deploy your changes once your PR is merged. This may take about 5-8 minutes to appear. Then simply refresh.