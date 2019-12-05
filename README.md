!!Very raw state!!

# WLForms

Alternative to FormObjects, focused on desktop Mathematica rather than Wolfram Cloud.


## Quick intro

The idea is to borrow as much as possible from FormObjects/FormFunctions and to adapt it for desktop gui creators' sake.

There are a few problems with FormObjects in MMA, which otherwise work well within the Cloud environment, that prompted me to create it.

- extracting values

  `Setting[formObject] @ "x"` is not very handy, 
  
  ``WLForms` `` allows you to do `form["x"]`. Or `form["State"]` to get them all.

- setting values

  `formObject @ <|"x" -> 1|>` is not very idiomatic and together with `Setting` it makes creating own field controllers weird
   
   ``WLForms` `` allows you to do `form["x"] = 1`
   
- custom field controllers

  The `formObject["x"]` automatically creating a controller is nice but it is either this or you need to assemble your controller from scratch.
  
  ``WLForms` `` allows you to do `FieldController @ whatever[Dynamic[form@"x"]]` and the `FieldController` wrapper will take care of labeling it in case of interpretation failure. Future releases will bring more features.
  
  I am also not a fan of warnings displayed as a part of the same layer of layout because it moves/changes the structure of everything so ``WLForms` `` uses `AttachedCell` to display warnings.
  
  
For a small example please see [Wiki](https://github.com/kubaPod/WLForms/wiki).     
   



## Installation
 
### Manual
 
   Go to 'releases' tab and download appropriate .paclet file.
    
   Run `PacletInstall @ path/to/the.paclet` file
   
### Via ``MPM` ``
   
If you don't have ``MPM` `` yet, run:
   
```Mathematica
Import[" https://raw.githubusercontent.com/kubapod/mpm/master/install.m"]
```   

and then:
   
```Mathematica
Needs @ "MPM`"     
MPMInstall["kubapod", "wlforms"]
```

