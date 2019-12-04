(* ::Package:: *)

(* ::Chapter:: *)
(* Metadata*)


(* Mathematica Package *)

(* :Title: WLForms *)
(* :Context: WLForms` *)
(* :Author: Kuba Podkalicki (kuba.pod@gmail.com) *)
(* :Date: Wed 4 Dec 2019 09:17:03 *)

(* :Keywords: *)
(* :Discussion: *)



(* ::Chapter:: *)
(* Begin package*)


BeginPackage["WLForms`"];

Unprotect["`*", "`*`*"]
ClearAll["`*", "`*`*"]

(* Needs and exported symbols here *)

Begin["`Private`"];



(* ::Chapter:: *)
(* Implementation code*)




FormQ = MatchQ[_Form];

formMutationHandler//Attributes={HoldAllComplete};

formMutationHandler[Set[(m_Symbol?FormQ)[field_],val_]]:=Module[
 {spec=m[[1]], new, isValid, wasValid}
, new = FieldInterpreter[spec[[field, "Interpreter"]]] @ val
; spec[[field, "Input"]] = val
; spec[[field, "Value"]] = new

; wasValid = Lookup[spec[[field]], "ValidQ", True]
; isValid = MatchQ[_Failure] @ new

; spec[field, "ValidQ" ] = isValid
; If[Echo[wasValid && Not @ isValid], FieldControllerMark[m[field], new] ]
; If[Not @ wasValid && isValid, FieldControllerUnmark[m[field]] ]

; spec["ValidQ"] = spec // Query[ FreeQ[_Failure] @* KeyDrop["ValidQ"], "Value"]
; m = Form @ spec
; new
]


FieldControllerMark // Attributes = {HoldAllComplete};
FieldControllerMark[form_Symbol?FormQ[field_], failure_]:= #["Mark", failure]& /@ Lookup[form[[1, field]], "controllers", {}]


FieldControllerUnmark // Attributes = {HoldAllComplete};
FieldControllerUnmark[form_Symbol?FormQ[field_]]:= #["Unmark"]& /@ Lookup[form[[1, field]], "controllers", {}]


FieldInterpreter[spec_String]:=Interpreter[spec]
FieldInterpreter[i_Interpreter]:=i


Language`SetMutationHandler[Form,formMutationHandler];


Form /: Form[spec_][key_]:= spec // Query[key, "Input"]


FieldController[con:_[Dynamic[sym_[field_], ___],___]]:=DynamicModule[
  {controllerRoot,style}
, Style[con, Background -> Dynamic @ style]
, Initialization :> (
    FieldControllerAdd[sym[field], controllerRoot]
  ; controllerRoot["Mark", failure_]:=style= Red
  ; controllerRoot["Unmark"]:=style= Black
  )
, Deinitialization :> FieldControllerRemove[sym[field], controllerRoot]
]


FieldControllerAdd // Attributes = {HoldAllComplete};
FieldControllerAdd[form_Symbol?FormQ[field_], root_]:= Module[{spec}
, spec = form[[1]] 
; spec[[field, "Controllers"]] = Union @ Flatten @  {Lookup[spec[field], "Controllers", {}], root}
; form = Form @ spec
]


FieldControllerRemove // Attributes = {HoldAllComplete};
FieldControllerRemove[form_Symbol?FormQ[field_], root_]:= Module[{spec}
, spec = form[[1]] 
; spec[[field, "Controllers"]] = DeleteCases[root] @ Lookup[ spec[field], "Controllers", {}]
; form = Form @ spec
]



(* ::Chapter:: *)
(* End package*)


End[];

EndPackage[];
