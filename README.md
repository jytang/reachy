# Reachy - Riichi Score Tracker

A demo program that helps you keep track of Japanese mahjong (Riichi) score
as you play.

* Able to keep track of multiple game sessions.
* Input each round result with winners and winning hands (number of
    _han_'s and _fu_'s, _mangan_, _yakuman_, etc.).
* Simple and straightforward interface for easy interaction.

## Quick Start

### 1. Requirements

* ruby 2.0 and above
* (Optional) cowsay

### 2. Installation and Usage

Simply install using [RubyGems](https://rubygems.org):
```
gem install reachy
```

Start the program. Ensure that the ``EXECUTABLE_DIRECTORY`` listed in ``gem env`` is in your ``$PATH``

```
reachy
```

Manual installation:
```
git clone https://github.com/jytang/reachy.git
cd reachy
gem build reachy.gemspec
gem install reachy-1.0.gem
```

## Note

```
                                                                /ysyo.
                                                               `ssssss-
                                                 `:///-`       /yssssss.
                                              `.+sssssy/      :ysssssy:
                                            `:osssssssy+     -yssssss-
                                          .+sssssssssyo.    :yssssy+`
                                        -oysssssssssssy/` `/yssssy:
                                      -oysssssssssso+ysss+oysssyo.
                                  `./sysssssssssssy. .oysssssss:``    :+-`
                              .:/+sssssyo++sssssso.   `-ssssy-`      -ysso/.
                    `-//:`` `sysssyys+:.  `+ysss:`  `..``/ysss:` ```/ysssssy/
                    `/yssso:``----.``    `/yss+.`   .hsy/`.oysys:./yssssso+/.
                      .osssss+-`       `:sysy-      -yssyo``:ysssysssss/.
                       `/yssssso/`   `-osssys`      -ysssyo  -ysssssy+`
                         `/syssssy+--oyssss:`       /ysssss``+ysssssyo`
                           `:oyssssssssso:` `      `oysssy: .o+osssssss:
                             `.+ysssssys``:ooooss- -ysssy/`    `-ssssssyo:``
                              `+yssssssyssssssso/``+yssy/`       .+ssssssss/``
                            `/sssssssssssssso-`   .yssy+`         `:sssssssss/`
                         `.+ssssssssooossssso:-:/+sssy+`     `.-///.-ssssssssss/.`
                       `:ossssys:.`    /ysssssssssssss```-:+osssssss-.ssssssssssss/-
                    `.+ssssss+-     `-+yssssso++oysssssssssssssso+o+. .ssssssssssssys+-``
                  .:ossssso/`  `.:+osssys+:.`` .ossoooosssssy/`        -ysssssssssssssss-
            `  `:osssssyo:```-+ssssssssyo-``  `sss-   `oysssh.          -ossssssssssssssy/`
            .:osssss+/:` .:+sssss+:.``-sssss+` ``     `sssssy-           `./+ssssssssssssss:`
        `-/osssss/.` `:+ssssss+-`     .sysssh`    `.-/oyssssyo///////+ossso/.`.:+ssssssssssso-
      -+ssssyo/.`    .++oooo/`   `.:/osssssss++++ossssssssssssssssssssssssssyy`   `-/osssssssy+`
     `://::-                `-:+osyysossssssssssssooossssssss+///:::::::----.`        `-/ossssss.
        `..`          `.:/ossssso/:.``ssssss:..``    -yssssy-                            ``-/oso.
        /yyo-.``.-:/oossssyo+:.`   `-ssssys.        .sssssss.      ``````
        .oysssyysssssss+/-`       .+ysssso.        :ssssssyo`   `/yysssyysso+/-`
         `/sssssssssss-``       `:sssssy+`       .+sssssssy:    `/yysssssssssssso/.
           `-:::--:+sssyo+:----/syssssy/`     `-oyssssssys:       `:ssssssssssssssy+`
                    `-/ssssssssssssssy/    `:+sssssssss+-`          .oyssssssssssssy:
                       `-+sssssssssss/` `:osssssssso/.`              .ssssssssssssss`
                          `:osssys/.`  `syssssso/-`                   :yssssssssyo/`
                             `.-.       .:+//.`                        .:+oo++:-`
```
