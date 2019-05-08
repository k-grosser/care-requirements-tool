(:~
 : Dieses Modul stellt Funktionen für die Generigung des HTML Inhalts für die Ansicht der Inkonsistenzen zur Verfügung
 : @version 1.1
 : @author Florian Eckey
:)
module namespace view="masterthesis/modules/care/view/consistency-view";

import module namespace util="masterthesis/modules/utilities";
import module namespace ui = 'masterthesis/modules/ui-manager';

(:~
: Diese Funktion generiert den HTML Inhalt für das Panel, in dem die Inkonsistenzen aufgelistet sind
: @param $current-package Das Paket, zu dem die Inkonsistenzen angezeigt wird
: @param $compare-package Das Paket, zu dem die Inkonsistenzen angezeigt wird
: @param $ref-id Die ID der Aktivität, zu der der Assistent angezeigt wird
: @param $req-id Ausgewählte ID der Anforderung, falls diese für die Bearbeitung angewählt wurde
: @param $inconsistencies Inkonsistenzen für die Aktivität mit ID $ref-id
: @return HTML-Seite für die Ansicht der Inkonsitenzen in der Assitenz-Ansicht
:)
declare function view:consistency-panel($current-package,$compare-package, $ref-id, $req-id, $inconsistencies) {
  <div class="collapse-panel re-collapse-panel consistency-panel {if($inconsistencies) then 'inconsistencies' else 'no-inconsistencies'}">
    <div class="header" data-toggle="collapse"  aria-expanded="false" aria-controls="collapseExample">
      <dl class="palette">
        <dt>{if($inconsistencies) then 'Inkonsistenzen' else 'Keine Inkonsistenzen'}{ui:info-tooltip("elicit.consistency")}</dt>
      </dl>
      
    </div>
    <div class="collapse {if($inconsistencies) then 'in' else ()}" id="collapseConsistency">
      {view:consistency-table($current-package,$compare-package, $ref-id, $req-id, $inconsistencies)}
    </div>
  </div>
};

(:~
: Diese Funktion generiert eine Tabelle, in der die Inkonsistenzen aufgelistet sind
: @param $current-package Das Paket, zu dem die Inkonsistenzen angezeigt wird
: @param $compare-package Das Paket, zu dem die Inkonsistenzen angezeigt wird
: @param $ref-id Die ID der Aktivität, zu der der Assistent angezeigt wird
: @param $req-id Ausgewählte ID der Anforderung, falls diese für die Bearbeitung angewählt wurde
: @param $inconsistencies Inkonsistenzen für die Aktivität mit ID $ref-id
: @return HTML-Seite für die Tabelle in der Ansicht der Inkonsitenzen in der Assitenz-Ansicht
:)
declare function view:consistency-table($current-package,$compare-package, $ref-id,$req-id, $inconsistencies) {
      <div class="panel-box inconsistencies-panel">
        {if($inconsistencies) then 
        <table class="table noindent">
          <!-- thead>
            <tr style="cursor:default">
              <th></th>
             </tr>
          </thead-->
          <tbody>
            {for $inconsistency in $inconsistencies return view:consistency-question-reference-list-item($inconsistency, $req-id)}
          </tbody>
        </table>
        else <div style="color:green">Keine Inkonsistenzen.</div>}
      </div>
};

(:~
: Diese Funktion generiert eine Zeile in der Tabelle der Inkonsistenzen
: @param $inconsistency Inkonsistenz, für die die Zeile generiert wird
: @param $req-id ID der Anforderung, welche die Inkoinsistenz betrifft
: @return HTML Tabellenzeile
:)
declare function view:consistency-question-reference-list-item($inconsistency, $req-id) {
  if($inconsistency) then
    <tr id="consistency-question{$inconsistency/@Id}" style="cursor:default" class="{if($inconsistency/@ReferenceId=$req-id) then 'list-active' else ()}">
      <td>{if($inconsistency/string()="") 
            then
              <span>Keine Frage zu Typ {$inconsistency/@Type/string()} gefunden.</span>
            else 
              $inconsistency/*}</td>
    </tr> 
  else ()
};