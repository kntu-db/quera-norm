# quera-db
## TODO
- [X] **Submit should be weak entity**
- [X] Role is enum so role entity should be removed
- [X] Change address to property
- [X] Link type is enum so linkType entity should be removed 
- [X] ProblemTag should be property
- [X] Add create relation between class and developer
- [X] Public practices in problemset
- [ ] ~~Add relation between company and contest (sponser)~~
- [X] User can be removed :|, add cascades
- [X] Add register date for users
- [X] Add public after archieve for class
- [X] Remove these entities and change to property: Semester, Address, LinkType, Field, ProblemTag, Advantage, TechnologyCategory, ProblemCategory
- [X] Convert all weak entities to strong entity (All entities should have id as primary key)
- [X] Remove entity company size and replace it to approximate size
- [X] Add on delete and on update for user and other entities that can be remove (based on documentation)
- [X] Convert extension to multi-valued property

## How to contribute
---
### using VSCode extension
- install [draw.io extension](https://marketplace.visualstudio.com/items?itemName=hediet.vscode-drawio) for vscode
- clone project and open working directory with vscode
- click on any file with `.drawio` extension it will automatically open in drawio editor
### using WebSite
- open [draw.io?mode=github](https://draw.io/?mode=github)
- click on "Open Existing Diagram" option
- authorize using github
