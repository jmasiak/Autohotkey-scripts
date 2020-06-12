PrepareToPrint()
{
	oWord := ComObjActive("Word.Application")
	OurTemplate := oWord.ActiveDocument.AttachedTemplate.FullName
	if (OurTemplate != "S:\OrgFirma\Szablony\Word\OgolneZmakrami\TQ-S402-en_OgolnyTechDok.dotm" && OurTemplate != "s:\OrgFirma\Szablony\Word\OgolneZmakrami\TQ-S402-pl_OgolnyTechDok.dotm")
	{
		MsgBox, 48, Zanim wydrukujesz..., 
		( Join	
1. Wykonaj makro, kt�re wstawi tward� spacj� po etykietach tabel i rysunk�w.`n
2. Od�wie� zawarto�� ca�ego dokumentu (Ctrl + F9).`n
3. Zamie� wszystkie odsy�acze na ��cza.`n
4. Ponownie od�wie� zawarto�� ca�ego dokumentu (Ctrl + F9).`n
5. Poszukaj s�owa "B��d".
		)
		
	}
	else
	{
		oWord.Run("TwardaSpacja")
		oWord.Run("UpdateFieldsPasek")
		MsgBox, 64, Microsoft Word, Od�wie�ono dokument
		oWord.Run("HiperlaczaPasek")
		MsgBox, 64, Microsoft Word, Zamieniono odsy�acze na ��cza
		oWord.Run("UpdateFieldsPasek")
		MsgBox, 64, Microsoft Word, Ponownie od�wie�ono dokument
		oWord.Selection.Find.ClearFormatting
		oWord.Selection.Find.Wrap := 1
		oWord.Selection.Find.Execute("B��d")
		if (oWord.Selection.Find.Found = -1)
		{
			Msgbox, 48, Microsoft Word, Znaleziono s�owo "B��d"
		}
		else
		{
			MsgBox, 64, Microsoft Word, Nie znaleziono s�owa "B��d"
		}
		
	}
	Send, {F12 down}{F12 up}
	oWord := ""
}