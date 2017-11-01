## About:

The goal of this project is to learn how to build something non-trivial with Elm. I chose [Typeform](https://www.typeform.com/) because it has a really slick user experience. This is not a replacement for Typeform or [Tellform](https://tellform.com/).

## Screenshot:

![Demo 01](https://github.com/dstreet26/elm-phoenix-typeform-clone/raw/master/Demo_01.gif)

## Demo:

(Heroku demo link coming soon!)

## TODO:

- Backend (Users, Database, etc.)
- Builder Interface
- More Question Types
- Select question from scroll position
- Smoother Animations

## Install:

### Requirements:

1. [Node.js](https://nodejs.org/en/)
2. [Elixir](http://elixir-lang.github.io/install.html) 
2. [Postgres](https://www.postgresql.org/download/) might also be required

### Commands: 

`git clone https://github.com/dstreet26/elm-phoenix-typeform-clone`

`cd elm-phoenix-typeform-clone`

`mix deps.get`

`cd assets`

`npm i`

`elm-package install -y`

`cd ..`

`mix phx.server`

Goto: [http://localhost:4000/](http://localhost:4000/)



## Greetings to the authors of elm packages used:
 - [identicalsnowflake/elm-dynamic-style](https://github.com/identicalsnowflake/elm-dynamic-style)
 - [ohanhi/keyboard-extra](https://github.com/ohanhi/keyboard-extra)
 - [pablohirafuji/elm-markdown](https://github.com/pablohirafuji/elm-markdown)
 - [wernerdegroot/listzipper](https://github.com/wernerdegroot/listzipper)
