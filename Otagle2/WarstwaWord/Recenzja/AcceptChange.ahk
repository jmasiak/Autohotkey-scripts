AcceptChange() ; zaakceptuj zmian�
{
	oWord := ComObjActive("Word.Application")
	oWord.Selection.Range.Revisions.AcceptAll ; Zaakceptuj zmian�
	oWord := ""
	WinActivate, ahk_class OpusApp
	return
}