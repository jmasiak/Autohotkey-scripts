RejectChange() ; odrzu� zmian�
{	
	oWord := ComObjActive("Word.Application")
	oWord.Selection.Range.Revisions.RejectAll ; Odrzu� zmian�
	oWord := ""
	WinActivate, ahk_class OpusApp
	return
}