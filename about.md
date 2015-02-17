---
layout: page
title: About
---

This site is a collaborative space for providing tutorials about MPI (the Message Passing Interface) and parallel programming. Below are more details about the primary writers on this site and how one can contribute to mpitutorial.com.

## Contributing

This site is hosted as a static page on [Github]({{ site.github.code }}). It is no longer actively contributed to by the original author, and any potential authors are encouraged to fork the repository [here]({{ site.github.code }}) and start writing a lesson!

Github uses Jekyll, a markdown-based blogging framework for producing static HTML pages. For an introduction on using Jekyll with Github, checkout [this article](https://help.github.com/articles/using-jekyll-with-pages/).

All lessons are self-contained in their own directories in the *tutorials* directory of the main repository. New tutorials should go under this directory, and any code for the tutorials should go in the *code* directory of the tutorial and provide a Makefile with executable examples. Similarly, the structure of the posts should match other tutorials.

For those that have never used Github or may feel overwhelmed about contributing a tutorial, contact Wes Kendall first at wesleykendall AT gmail DOT com. If you wish to write a tutorial with images as a Microsoft Word document or PDF, I'm happy to translate the lesson into the proper format for the site.

> **Note** - The tutorials on this site need to remain as informative as possible and encompass useful topics related to MPI. Before writing a tutorial, collaborate with me through email (wesleykendall AT gmail DOT com) if you want to propose a lesson to the beginning MPI tutorial. Similarly, we can also start an advanced MPI tutorial page for more advanced topics.

## Authors

### Wes Kendall
Wes Kendall is the original author of mpitutorial.com. As a graduate student at the University of Tennessee, Knoxville, Wes earned his PhD under Jian Huang. His research revolved around large-scale data analysis and visualization, and he worked with the biggest supercomputers in the world. As a graduate student, he interned at Google, Oak Ridge National Labs, and Argonne National Labs. His research also earned him the Supercomputing 2011 Best Student Paper Award. He is currently co-founder and CTO of Ambition, a data-analytics startup funded by YCombinator, Google Ventures, and several other top investment firms.

Disappointed with the amount of freely-available content on parallel programming and MPI, Wes started releasing tutorials on the subject after graduate school. Once his startup consumed most of his time, he opened up mpitutorial.com to the public on github.com so that others could start contributing high-quality content.
