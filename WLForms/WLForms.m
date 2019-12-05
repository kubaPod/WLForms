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

  Needs @ "GeneralUtilities`";

  Unprotect["`*", "`*`*"]
  ClearAll["`*", "`*`*"]

  Form;
  FieldController;



Begin["`Private`"];



(* ::Chapter:: *)
(* Implementation code*)




FormQ = MatchQ[_Form];

$nonFieldKeys = {"ValidQ"};

Form[spec_][key_]:= spec // Query[key, "Input"]
Form[spec_][key_, "Controllers"]:=  Lookup[ spec[[key]], "Controllers", {}]
Form[spec_][key : Alternatives @@ $nonFieldKeys]:=  Lookup[ spec, key]

Form[spec_]["State"]:= KeyDrop[spec, $nonFieldKeys][[All, "Value"]]

formMutationHandler//Attributes={HoldAllComplete};

formMutationHandler[Set[(m_?FormQ)[field_],val_]]:=Module[
 {spec=m[[1]], new, isValid, wasValid}

, new = FieldInterpreter[spec[[field, "Interpreter"]]] @ val
; spec[[field, "Input"]] = val
; spec[[field, "Value"]] = new

; wasValid = Lookup[spec[[field]], "ValidQ", True]
; isValid = Not @ MatchQ[_Failure] @ new

; spec[field, "ValidQ" ] = isValid

; If[ wasValid && !isValid, FieldControllerMark[m[field], new] ]
; If[!wasValid &&  isValid, FieldControllerUnmark[m[field]] ]

; spec["ValidQ"] = spec // Query[ FreeQ[_Failure | _Missing] @* KeyDrop[$nonFieldKeys], "Value"]
; m = Form @ spec
; new
]


FieldControllerMark // Attributes = {HoldAllComplete};
FieldControllerMark[form_?FormQ[field_], failure_]:= #["Mark", failure]& /@ form[field, "Controllers"]

FieldControllerUnmark // Attributes = {HoldAllComplete};
FieldControllerUnmark[form_?FormQ[field_]]:= #["Unmark"]& /@ form[field, "Controllers"]


FieldInterpreter[spec_]:=Interpreter[spec]
FieldInterpreter[i_Interpreter]:=i


Language`SetMutationHandler[Form,formMutationHandler];



FieldController::usage = "FieldController @ controller_[Dynamic[form@field],___] wraps the controller in the "<>
  "box structure that 'subscribes' to the form's field changes and displays failure strings "<>
  "when an invalid input is set for form@field.

Supported forms:

FieldController @ standardController @ Dynamic @ form @ \"x\", where standardController can e.g. be an InputField

FieldController[ Dynamic[field@\"x\"], nonStandardController_]

FieldController[Dynamic[field@\"x\"] ] @ controller_
"

FieldController // Attributes = {HoldFirst}

FieldController[spec : Dynamic[_Symbol?FormQ[_], ___]]:=Function[controller, FieldController[spec, controller] ]

FieldController[con:_[spec:Dynamic[_Symbol?FormQ[_], ___],___]]:=FieldController[spec, con]

FieldController[Dynamic[form_Symbol?FormQ[field_], ___], controller_] := DynamicModule[
  {controllerRoot, thisBox}
, controller
, Initialization :> (
    thisBox = EvaluationBox[]

  ; FieldControllerAdd[form[field], controllerRoot]


  ; controllerRoot["Mark", failure_]:= (
      controllerRoot["Unmark"]
    ; controllerRoot["warningCell"] = AddWarning[thisBox, failure]
    )
  ; controllerRoot["Unmark"]:= (
      RemoveWarning[controllerRoot["warningCell"]]
    ; controllerRoot["warningCell"] = {}
    )
  )
, Deinitialization :> FieldControllerRemove[form[field], controllerRoot]
]

AddWarning[box_BoxObject, msg_Failure]:= AddWarning[box, FailureString @ msg];
AddWarning[box_BoxObject, msg_]:= FrontEndExecute @ FrontEnd`AttachCell[
  box
, Cell[ BoxData @ ToBoxes @ msg, "Message"]
, {Automatic, {Left, Bottom}}
, {Left, Top}
, "ClosingActions" -> {"EvaluatorQuit"}
]



RemoveWarning[cell_CellObject]:= NotebookDelete @ cell;

FieldControllerAdd // Attributes = {HoldAllComplete};
FieldControllerAdd[form_?FormQ[field_], root_]:= Module[{spec}
, spec = form[[1]] 
; spec[[field, "Controllers"]] = Union @ Flatten @  {form[field, "Controllers"], root}
; form = Form @ spec
]


FieldControllerRemove // Attributes = {HoldAllComplete};
FieldControllerRemove[form_?FormQ[field_], root_]:= Module[{spec}
, spec = form[[1]] 
; spec[[field, "Controllers"]] = DeleteCases[root] @ form[field,"Controllers"]
; form = Form @ spec
]



(* ::Chapter:: *)
(* End package*)


End[];

EndPackage[];
