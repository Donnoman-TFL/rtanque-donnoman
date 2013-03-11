# Donnoman's Tanques

https://github.com/awilliams/RTanque

OSX users using BREW can install Gosu with 

    $ brew install gosu
    $ cp .rvmrc.template .rvmrc
    $ bundle install --binstub

    $ bin/rtanque new_bot my_deadly_bot
    $ bin/rtanque start bots/my_deadly_bot sample_bots/keyboard sample_bots/camper:x2

To Run all non-sample bots:

    $ bin/rtanque start bots/*
