<%@ include file="/WEB-INF/template/include.jsp" %>
<%@ taglib prefix="mpcw" uri="/WEB-INF/view/module/htmlformflowsheet/taglib/htmlformflowsheet.tld" %>

<%--
Parameters:
	encounterTypeId: (int, required) tells what encounter type to show in this table
					 use the special value '*' to signify all encounters regardless of type
	conceptsToShow: (comma-separated list of concept ids) tells what concepts to show the
					obs of in the table. If not specified, then all concepts will be extracted
					from the specified form (not yet implemented)
	showAddAnother: (boolean, default = true) if 'false', there's no option for "add another"
	formId: which form to use for the "add another"
--%>

<%--
	(Internal documentation)
	passed from controller:
	* encounterListForChart: list of encounters
--%>



<script src='<%= request.getContextPath() %>/dwr/interface/HtmlFlowsheetDWR.js'></script>

<%-- If there are any encounters, we show a chart --%>
<script type="text/javascript">
	var $j = jQuery.noConflict();
	$j(document).ready(function() {
		$j('#encounterChartPopup${model.portletUUID}').dialog({
				title: 'TODO: put encounter details here dynamically',
				autoOpen: false,
				draggable: false,
				resizable: false,
				width: '95%',
				modal: true
		});
	});

	function closeEncounterChartPopup${model.portletUUID}() {	 
		//$j("#encounterChartPopup${model.portletUUID}").dialog('close');
			$j(".ui-widget-content").dialog('close');
	}
	
	function voidEncounter${model.portletUUID}(uuid, id, retVal){
		if (retVal == true){
			HtmlFlowsheetDWR.voidEncounter(id ,function(ret){
								if (!ret)
									alert('<spring:message code="htmlformflowsheet.cantdeleteencounter" />');
								else
									$j('#encounterWidget_' + uuid).load( openmrsContextPath + "/module/htmlformflowsheet/encounterChartContent.list?patientId=${model.personId}&portletUUID=" + uuid +"&encounterTypeId=${model.encounterTypeId}&view=${model.view}&formId=${model.formId}&count=${model.view + 1}"); 
							});
			
		}
	}
	
	function editHTMLForm${model.portletUUID}(encId,view){
		window.location = '${pageContext.request.contextPath}/module/htmlformentry/htmlFormEntry.form?encounterId=' + encId + '&mode=EDIT&returnUrl=${pageContext.request.contextPath}/module/htmlformflowsheet/testChart.list?selectTab=' + view;
	}
	
</script>
<table id="encContentTable${model.portletUUID}" class="thinBorder" style="width:100%;">
	<tr>
		<td colspan="2" style="color:darkblue">Encounter</td>
		<c:forEach var="concept" items="${model.encounterChartConcepts}">
			<td style="color:darkblue"><mpcw:conceptFormat concept="${concept}" shortestName="true" /></td>
		</c:forEach>
	</tr>
	<c:forEach var="enc" items="${model.encounterListForChart}">
		<tr>
			<td style="width:38px">
			 <c:if test="${model.readOnly == 'false'}">
				<input type="image" src="${pageContext.request.contextPath}/images/file.gif"  
					    name="editEncounter" 
						onclick="resizeIFrame${model.portletUUID}(350);showEncounterEditPopup('${model.portletUUID}',${enc.encounterId}, ${model.personId}, ${model.formId}, ${model.view}, ${model.encounterTypeId})"
						title="edit" 
						alt="edit"/>			
				<input type="image" src="${pageContext.request.contextPath}/images/trash.gif"  
					    name="voidEncounter" 
						onclick="voidEncounter${model.portletUUID}('${model.portletUUID}',${enc.encounterId}, confirm('<spring:message code="Are you sure you want to delete this encounter?"/>'));" 
						title="<spring:message code="htmlformflowsheet.deleteEncounters"/>" 
						alt="<spring:message code="htmlformflowsheet.deleteEncounters"/>"/>
             </c:if>
			</td>
			<td>
				<a href="javascript:void(0)" onClick="resizeIFrame${model.portletUUID}(350);showEncounterPopup('${model.portletUUID}', ${enc.encounterId},${model.formId})">
					<openmrs:formatDate date="${enc.encounterDatetime}"/>
				</a>
			</td>
			<c:forEach var="concept" items="${model.encounterChartConcepts}">
				<td>
					<c:forEach var="obs" items="${model.encounterChartObs[enc][concept.conceptId]}">
						<c:if test="${obs.valueCoded != null}">
							<mpcw:conceptFormat concept="${obs.valueCoded}" bestShortName="true" />
						</c:if>
						<c:if test="${obs.valueCoded == null}">
							<openmrs:format obsValue="${obs}"/> 
						</c:if>
						<c:if test="${obs.accessionNumber != null}"> (${obs.accessionNumber})</c:if><br/>
					</c:forEach>
				</td>
			</c:forEach>
		</tr>
	</c:forEach>
	<c:if test="${model.showAddAnother != 'false' && model.readOnly == 'false'}"> 
		<tr>
			<td colspan="${fn:length(model.encounterChartConcepts) + 2}" align="center">
				<button onClick="resizeIFrame${model.portletUUID}(350);showEntryPopup('${model.portletUUID}', ${model.personId}, ${model.formId}, ${model.view}, ${model.encounterTypeId} );"> 
					Add Another 
				</button>
			</td>
		</tr>	
	</c:if>
</table>

<div id="encounterChartPopup${model.portletUUID}">
	<iframe id="encounterChartIFrame${model.portletUUID}" width="100%" height="100%" marginWidth="0" marginHeight="0" frameBorder="0" scrolling="auto"></iframe>
</div>
<%-- Maybe show an "Add Another button --%>

<script>

				   try {
						var p = parent;
						var x = $j(parent.document).find('#iframeFor${model.formId}');
						if (x.length == 1){
							var frame = x[0];
							var height = $j('#encContentTable${model.portletUUID}').outerHeight(true) + 24;
							frame.style.height = height+'px';
						}	
				   } catch (exception){} 
			   function resizeIFrame${model.portletUUID}(extraSpace){
				   try {
						var x = $j(parent.document).find('#iframeFor${model.formId}');
						if (x.length == 1)
							frame.style.height = extraSpace + 'px';
				   } catch (exception){} 
			    }
</script>
