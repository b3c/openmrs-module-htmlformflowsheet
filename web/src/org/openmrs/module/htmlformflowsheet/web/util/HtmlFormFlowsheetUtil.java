package org.openmrs.module.htmlformflowsheet.web.util;

import java.util.StringTokenizer;

import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;
import org.openmrs.Form;
import org.openmrs.api.APIException;
import org.openmrs.api.context.Context;
import org.openmrs.module.htmlformflowsheet.web.EncounterChartPatientChartTab;
import org.openmrs.module.htmlformflowsheet.web.HtmlFormFlowsheetContextAware;
import org.openmrs.module.htmlformflowsheet.web.PatientChartConfiguration;
import org.openmrs.module.htmlformflowsheet.web.SingleHtmlFormPatientChartTab;
import org.openmrs.module.htmlformflowsheet.web.controller.PatientChartController;
import org.springframework.context.ApplicationContext;

public class HtmlFormFlowsheetUtil {
  
    private static Log log = LogFactory.getLog(HtmlFormFlowsheetUtil.class);

    /**
     * 
     * Automatically configure the module based on the global properties.
     *
     */
    public static void configureTabsAndLinks(){
        ApplicationContext ac = null;
        try {
            PatientChartConfiguration config = getConfiguration();
            configureTabsAndLinks(config);
        } catch (APIException apiEx){
            
        }
    }
    
    /**
     * 
     * Method that will generically return a PatientChartConfiguration from the config strings
     * This is for URL-parameters override of default configuration that usually lives in the controller.
     * 
     * @param gp
     * @param linksGP
     * @return
     */
    public static PatientChartConfiguration buildGenericConfigurationFromStrings(String gp, String linksGP){
        PatientChartConfiguration config = new PatientChartConfiguration();
        configureTabsAndLinks(config, gp, linksGP);
        return config;
    }
    
    
    /**
     * Get the patient PatientChartConfiguration out of the session.
     * the PatientChartConfiguration is a property of the controller
     * 
     * @return
     */
    protected static PatientChartConfiguration getConfiguration(){
        ApplicationContext ac = null;
        try{
            ac = HtmlFormFlowsheetContextAware.getApplicationContext();
            String[] names = ac.getBeanNamesForType(PatientChartController.class);
            PatientChartController pcc = (PatientChartController) ac.getBean(names[0]);
            PatientChartConfiguration config = pcc.getConfiguration();
            return config;
        } catch (APIException apiEx){
            return null;
        }
    }
    
    
    /**
     * 
     * Grabs the configuration global properties and configures the tab layout and links for the module
     * 
     * @param config
     */
    protected static void configureTabsAndLinks(PatientChartConfiguration config){
        
        String gp = Context.getAdministrationService().getGlobalProperty("htmlformflowsheet.configuration");
        String linksGP = Context.getAdministrationService().getGlobalProperty("htmlformflowsheet.links");
        
        if (config != null)
            configureTabsAndLinks(config, gp,linksGP);
        else 
            log.error("Unable to configure HtmlFormFlowsheet -- configuration object is null");

    }
    
    
    /**
     * 
     * Helper class that does the configuration work
     * 
     * @param config
     * @param gp
     * @param linksGP
     */
    protected static void configureTabsAndLinks(PatientChartConfiguration config, String gp, String linksGP){
            if (gp != null && !"".equals(gp)){
                config.getTabs().clear();
                for (StringTokenizer st = new StringTokenizer(gp, "|"); st.hasMoreTokens(); ) {
                    String thisTag = st.nextToken().trim();
                    String[] tagString = thisTag.split(":");
                    if (tagString.length == 3){
                        //Flowsheet
                        EncounterChartPatientChartTab ecct = new EncounterChartPatientChartTab();
                        ecct.setShowAddAnother(true);
                        Form form = Context.getFormService().getForm(Integer.valueOf(tagString[2]));
                        ecct.setFormId(form.getFormId());
                        ecct.setEncounterTypeId(form.getEncounterType().getEncounterTypeId());
                        ecct.setTitle(tagString[1]);
                        config.addTab(ecct);
                    } else if (tagString.length == 4){
                        //Single Form
                        SingleHtmlFormPatientChartTab shpt = new SingleHtmlFormPatientChartTab();
                        Form form = Context.getFormService().getForm(Integer.valueOf(tagString[2]));
                        shpt.setFormId(form.getFormId());
                        shpt.setDefaultEncounterTypeId(form.getEncounterType().getEncounterTypeId());
                        shpt.setTitle(tagString[1]);
                        shpt.setWhich(SingleHtmlFormPatientChartTab.Which.valueOf(tagString[3]));
                        config.addTab(shpt);
                    }
                }
            }
            if (linksGP != null && !linksGP.equals("")){
                config.getLinks().clear();
                for (StringTokenizer st = new StringTokenizer(linksGP, "|"); st.hasMoreTokens(); ) {
                    String thisTag = st.nextToken().trim();
                    String[] tagString = thisTag.split(":");
                    if (tagString.length == 2){
                        String name = tagString[0];
                        String link = tagString[1];
                        config.addLink(name, link);
                    }
                }    
            }
    }
          
}