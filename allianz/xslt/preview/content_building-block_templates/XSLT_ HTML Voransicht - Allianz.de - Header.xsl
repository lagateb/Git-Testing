<xsl:stylesheet version="2.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:xi="http://www.w3.org/2001/XInclude"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                xmlns:xlink="http://www.w3.org/1999/xlink"
                xmlns:cs="http://www.censhare.com/xml/3.0.0/xpath-functions"
                xmlns:svtx="http://www.savotex.com"
                exclude-result-prefixes="#all">

  <!-- output -->
  <xsl:output method="xhtml" indent="yes" encoding="UTF-8" omit-xml-declaration="yes"/>

  <!-- parameter -->
  <xsl:param name="mode" select="()"/>
  <xsl:param name="scale" select="1.0"/>

  <!-- variables -->
  <xsl:variable name="debug" select="false()" as="xs:boolean"/>
  <xsl:variable name="rootAsset" select="asset[1]" as="element(asset)?"/>
  <xsl:variable name="urlPrefix" select="if ($mode = 'browser') then '/ws/rest/service/' else if ($mode='cs5') then '/censhare5/client/rest/service/' else '/service/'" as="xs:string"/>

  <xsl:template match="content">
    <!-- NAVBAR -->
    <div class="root responsivegrid">
      <div class="header-container parsys aem-GridColumn aem-GridColumn--default--12">
        <div class="aem-Grid aem-Grid--12 aem-Grid--default--12 ">
          <div class="allianzde-header parbase aem-GridColumn aem-GridColumn--default--12">
            <header class="c-azde-header js-azde-header c-azde-agency-context--none">
              <div class="c-azde-header__drawer ">
                <div class="c-azde-header__drawer__wrapper">
                  <div class="c-azde-header__tied-agent__mobile-placeholder">
                  </div>
                  <div class="c-azde-header__navigation">
                    <div class="aem-Grid aem-Grid--12 aem-Grid--default--12 ">
                      <div class="navigation container aem-GridColumn aem-GridColumn--default--12">
                        <nav id="main-nav" class="c-azde-navigation js-azde-navigation" aria-label="Main">
                        <ul id="headermenubar" class="c-azde-navigation__list" itemscope="" itemtype="https://www.schema.org/SiteNavigationElement">
                          <li class="c-azde-navigation__topic c-azde-navigation__topic--tablet-group">
                            <span class="c-azde-navigation__topic__title c-azde-navigation__topic__title--tablet-group" aria-expanded="false" role="button" aria-label="Produkte" tabindex="-1">
                              Produkte
                            </span>
                            <ul id="tabletgroupbar" class="c-azde-navigation__tablet-group__list" style="height: 0px; min-height: 0px;"></ul>
                          </li>
                          <li class="c-azde-navigation__topic c-azde-navigation__topic__tablet-group-element">
                            <span class="c-azde-navigation__topic__title js-azde-navigation__topic__title--tablet-group" aria-expanded="false" role="button" tabindex="0">
                              Auto, Haus &amp; Recht
                              <span class="c-icon c-icon--chevron-down c-azde-navigation__topic__title__icon" aria-hidden="true"></span>
                            </span>
                            <div class="c-azde-navigation__topic__list" style="height: 0px;">
                              <div class="l-grid l-grid--max-width">
                                <div class="l-grid__row c-azde-navigation__topic__list__row" role="group" >
                                </div>
                                <div class="l-grid__row c-azde-navigation__topic__teasers-row c-azde-navigation__topic__teasers-row--two-teasers-size">
                                  <div class="l-grid__column-medium-6 l-grid__column-large-4 c-azde-navigation__teaser__wrapper">
                                    <div class="js-azde-navigation__teaser c-azde-navigation__teaser  js-agency-licence-hide-parent">
                                      <div class="c-azde-navigation__teaser__image__wrapper ">
                                        <picture class="cmp-image c-image  c-azde-navigation__teaser__image ">
                                          <!--<img src="/etc.clientlibs/onemarketing/platform/clientlibs/aem-core/resources/images/1px.gif" srcset="/content/experience-fragments/onemarketing/azde/azd/de_DE/azde_navigation/allianz-de-navigation/allianz-de-navigation/_jcr_content/root/navigation/navigation-topic-parsys/navigation_topic/navigation-teaser-parsys/navigation_teaser/teaser-image.img.60.320.jpeg/1553507084318/ampel-gruener-wirds-nicht-flyout.jpeg 320w,/content/experience-fragments/onemarketing/azde/azd/de_DE/azde_navigation/allianz-de-navigation/allianz-de-navigation/_jcr_content/root/navigation/navigation-topic-parsys/navigation_topic/navigation-teaser-parsys/navigation_teaser/teaser-image.img.60.640.jpeg/1553507084318/ampel-gruener-wirds-nicht-flyout.jpeg 640w,/content/experience-fragments/onemarketing/azde/azd/de_DE/azde_navigation/allianz-de-navigation/allianz-de-navigation/_jcr_content/root/navigation/navigation-topic-parsys/navigation_topic/navigation-teaser-parsys/navigation_teaser/teaser-image.img.60.768.jpeg/1553507084318/ampel-gruener-wirds-nicht-flyout.jpeg 768w,/content/experience-fragments/onemarketing/azde/azd/de_DE/azde_navigation/allianz-de-navigation/allianz-de-navigation/_jcr_content/root/navigation/navigation-topic-parsys/navigation_topic/navigation-teaser-parsys/navigation_teaser/teaser-image.img.60.1280.jpeg/1553507084318/ampel-gruener-wirds-nicht-flyout.jpeg 1280w,/content/experience-fragments/onemarketing/azde/azd/de_DE/azde_navigation/allianz-de-navigation/allianz-de-navigation/_jcr_content/root/navigation/navigation-topic-parsys/navigation_topic/navigation-teaser-parsys/navigation_teaser/teaser-image.img.60.1920.jpeg/1553507084318/ampel-gruener-wirds-nicht-flyout.jpeg 1920w,/content/experience-fragments/onemarketing/azde/azd/de_DE/azde_navigation/allianz-de-navigation/allianz-de-navigation/_jcr_content/root/navigation/navigation-topic-parsys/navigation_topic/navigation-teaser-parsys/navigation_teaser/teaser-image.img.60.3360.jpeg/1553507084318/ampel-gruener-wirds-nicht-flyout.jpeg 3360w" alt="Kfz-Versicherung Allianz - Grüne Ampel, Auto hat freie Fahrt" sizes="258px" data-component-id="root/navigation/navigation-topic-parsys/navigation_topic/navigation-teaser-parsys/navigation_teaser/teaser-image" class="c-image__img c-azde-navigation__teaser__image__img c-teaser__image-img">-->
                                        </picture>
                                      </div>
                                      <div class="c-azde-navigation__teaser__content">
                                        <span class="c-heading  c-heading--subsection-xsmall c-azde-navigation__teaser__headline c-link--capitalize u-text-hyphen-auto">
                                          Kfz-Versicherung
                                        </span>
                                        <div class="c-copy     u-text-hyphen-auto">
                                          Jetzt wechseln und sparen!
                                        </div>
                                        <div class="c-azde-navigation__teaser__bottom">
                                          <a class="c-link c-link--block" href="https://www.allianz.de/auto/kfz-versicherung/" target="_self" data-link-title="Mehr erfahren" aria-label="Mehr erfahren" data-component-id="root/navigation/navigation-topic-parsys/navigation_topic/navigation-teaser-parsys/navigation_teaser/teaser-link">
                                            <span aria-hidden="true" class="c-link__icon c-icon c-icon--arrow-right"></span>
                                            <span class="c-link__text">Mehr erfahren</span>
                                          </a>
                                        </div>
                                      </div>
                                    </div>
                                  </div>
                                  <div class="l-grid__column-medium-6 l-grid__column-large-4 c-azde-navigation__teaser__wrapper">
                                    <div class="js-azde-navigation__teaser c-azde-navigation__teaser  js-agency-licence-hide-parent">
                                      <div class="c-azde-navigation__teaser__image__wrapper ">
                                        <picture class="cmp-image c-image  c-azde-navigation__teaser__image ">
                                          <!--<img src="/etc.clientlibs/onemarketing/platform/clientlibs/aem-core/resources/images/1px.gif" srcset="/content/experience-fragments/onemarketing/azde/azd/de_DE/azde_navigation/allianz-de-navigation/allianz-de-navigation/_jcr_content/root/navigation/navigation-topic-parsys/navigation_topic/navigation-teaser-parsys/navigation_teaser_693732342/teaser-image.img.60.320.jpeg/1562665887116/privatschutz-kind-spielt-im-karton-fliegerbrille-schal-1920x1200.jpeg 320w,/content/experience-fragments/onemarketing/azde/azd/de_DE/azde_navigation/allianz-de-navigation/allianz-de-navigation/_jcr_content/root/navigation/navigation-topic-parsys/navigation_topic/navigation-teaser-parsys/navigation_teaser_693732342/teaser-image.img.60.640.jpeg/1562665887116/privatschutz-kind-spielt-im-karton-fliegerbrille-schal-1920x1200.jpeg 640w,/content/experience-fragments/onemarketing/azde/azd/de_DE/azde_navigation/allianz-de-navigation/allianz-de-navigation/_jcr_content/root/navigation/navigation-topic-parsys/navigation_topic/navigation-teaser-parsys/navigation_teaser_693732342/teaser-image.img.60.768.jpeg/1562665887116/privatschutz-kind-spielt-im-karton-fliegerbrille-schal-1920x1200.jpeg 768w,/content/experience-fragments/onemarketing/azde/azd/de_DE/azde_navigation/allianz-de-navigation/allianz-de-navigation/_jcr_content/root/navigation/navigation-topic-parsys/navigation_topic/navigation-teaser-parsys/navigation_teaser_693732342/teaser-image.img.60.1280.jpeg/1562665887116/privatschutz-kind-spielt-im-karton-fliegerbrille-schal-1920x1200.jpeg 1280w,/content/experience-fragments/onemarketing/azde/azd/de_DE/azde_navigation/allianz-de-navigation/allianz-de-navigation/_jcr_content/root/navigation/navigation-topic-parsys/navigation_topic/navigation-teaser-parsys/navigation_teaser_693732342/teaser-image.img.60.1920.jpeg/1562665887116/privatschutz-kind-spielt-im-karton-fliegerbrille-schal-1920x1200.jpeg 1920w,/content/experience-fragments/onemarketing/azde/azd/de_DE/azde_navigation/allianz-de-navigation/allianz-de-navigation/_jcr_content/root/navigation/navigation-topic-parsys/navigation_topic/navigation-teaser-parsys/navigation_teaser_693732342/teaser-image.img.60.3360.jpeg/1562665887116/privatschutz-kind-spielt-im-karton-fliegerbrille-schal-1920x1200.jpeg 3360w" alt="Hausratversicherung Allianz - Frau in den eigenen vier Wänden" sizes="258px" data-component-id="root/navigation/navigation-topic-parsys/navigation_topic/navigation-teaser-parsys/navigation_teaser_693732342/teaser-image" class="c-image__img c-azde-navigation__teaser__image__img c-teaser__image-img">-->
                                        </picture>
                                      </div>
                                      <div class="c-azde-navigation__teaser__content">
                                        <span class="c-heading  c-heading--subsection-xsmall c-azde-navigation__teaser__headline c-link--capitalize u-text-hyphen-auto">
                                          Allianz Privatschutz
                                        </span>
                                        <div class="c-copy u-text-hyphen-auto">
                                          Sicherheit im Alltag - günstig im Paket.
                                        </div>
                                        <div class="c-azde-navigation__teaser__bottom">
                                          <a class="c-link c-link--block" href="https://privatschutz.allianz.de/" target="_blank" data-link-title="Mehr erfahren" aria-label="Mehr erfahren" data-component-id="root/navigation/navigation-topic-parsys/navigation_topic/navigation-teaser-parsys/navigation_teaser_693732342/teaser-link">
                                            <span aria-hidden="true" class="c-link__icon c-icon c-icon--arrow-right"></span>
                                            <span class="c-link__text">Mehr erfahren</span>
                                          </a>
                                        </div>
                                      </div>
                                    </div>
                                  </div>
                                </div>
                              </div>
                            </div>
                          </li>
                          <li class="c-azde-navigation__topic c-azde-navigation__topic__tablet-group-element">
                            <span class="c-azde-navigation__topic__title js-azde-navigation__topic__title--tablet-group" aria-expanded="false" role="button" tabindex="-1">
                              Gesundheit &amp; Freizeit
                              <span class="c-icon c-icon--chevron-down c-azde-navigation__topic__title__icon" aria-hidden="true"></span>
                            </span>
                            <div class="c-azde-navigation__topic__list" style="height: 0px;">
                              <div class="l-grid l-grid--max-width">
                                <div class="l-grid__row c-azde-navigation__topic__list__row" role="group" aria-label="Gesundheit &amp; Freizeit">
                                </div>
                                <div class="l-grid__row c-azde-navigation__topic__teasers-row c-azde-navigation__topic__teasers-row--two-teasers-size">
                                  <div class="l-grid__column-medium-6 l-grid__column-large-4 c-azde-navigation__teaser__wrapper">
                                    <div class="js-azde-navigation__teaser c-azde-navigation__teaser  js-agency-licence-hide-parent">
                                      <div class="c-azde-navigation__teaser__image__wrapper ">
                                        <picture class="cmp-image c-image  c-azde-navigation__teaser__image ">
                                          <!--<img src="/etc.clientlibs/onemarketing/platform/clientlibs/aem-core/resources/images/1px.gif" srcset="/content/experience-fragments/onemarketing/azde/azd/de_DE/azde_navigation/allianz-de-navigation/allianz-de-navigation/_jcr_content/root/navigation/navigation-topic-parsys/navigation_topic_1660317978/navigation-teaser-parsys/navigation_teaser/teaser-image.img.60.320.jpeg/1579512697654/zahnzusatz-flyout.jpeg 320w,/content/experience-fragments/onemarketing/azde/azd/de_DE/azde_navigation/allianz-de-navigation/allianz-de-navigation/_jcr_content/root/navigation/navigation-topic-parsys/navigation_topic_1660317978/navigation-teaser-parsys/navigation_teaser/teaser-image.img.60.640.jpeg/1579512697654/zahnzusatz-flyout.jpeg 640w,/content/experience-fragments/onemarketing/azde/azd/de_DE/azde_navigation/allianz-de-navigation/allianz-de-navigation/_jcr_content/root/navigation/navigation-topic-parsys/navigation_topic_1660317978/navigation-teaser-parsys/navigation_teaser/teaser-image.img.60.768.jpeg/1579512697654/zahnzusatz-flyout.jpeg 768w,/content/experience-fragments/onemarketing/azde/azd/de_DE/azde_navigation/allianz-de-navigation/allianz-de-navigation/_jcr_content/root/navigation/navigation-topic-parsys/navigation_topic_1660317978/navigation-teaser-parsys/navigation_teaser/teaser-image.img.60.1280.jpeg/1579512697654/zahnzusatz-flyout.jpeg 1280w,/content/experience-fragments/onemarketing/azde/azd/de_DE/azde_navigation/allianz-de-navigation/allianz-de-navigation/_jcr_content/root/navigation/navigation-topic-parsys/navigation_topic_1660317978/navigation-teaser-parsys/navigation_teaser/teaser-image.img.60.1920.jpeg/1579512697654/zahnzusatz-flyout.jpeg 1920w,/content/experience-fragments/onemarketing/azde/azd/de_DE/azde_navigation/allianz-de-navigation/allianz-de-navigation/_jcr_content/root/navigation/navigation-topic-parsys/navigation_topic_1660317978/navigation-teaser-parsys/navigation_teaser/teaser-image.img.60.3360.jpeg/1579512697654/zahnzusatz-flyout.jpeg 3360w" alt="Zahnzusatzversicherung Allianz - bezauberndes Lächeln" sizes="258px" data-component-id="root/navigation/navigation-topic-parsys/navigation_topic_1660317978/navigation-teaser-parsys/navigation_teaser/teaser-image" class="c-image__img c-azde-navigation__teaser__image__img c-teaser__image-img">-->
                                        </picture>
                                      </div>
                                      <div class="c-azde-navigation__teaser__content">
                                        <span class="c-heading  c-heading--subsection-xsmall c-azde-navigation__teaser__headline c-link--capitalize u-text-hyphen-auto">
                                          Zahnzusatzversicherung
                                        </span>
                                        <div class="c-copy u-text-hyphen-auto">
                                          Starke Leistung für starke Zähne
                                        </div>
                                        <div class="c-azde-navigation__teaser__bottom">
                                          <a class="c-link c-link--block" href="https://www.allianz.de/gesundheit/zahnzusatzversicherung/" target="_self" data-link-title="Mehr erfahren" aria-label="Mehr erfahren" data-component-id="root/navigation/navigation-topic-parsys/navigation_topic_1660317978/navigation-teaser-parsys/navigation_teaser/teaser-link">
                                            <span aria-hidden="true" class="c-link__icon c-icon c-icon--arrow-right"></span>
                                            <span class="c-link__text">Mehr erfahren</span>
                                          </a>
                                        </div>
                                      </div>
                                    </div>
                                  </div>
                                  <div class="l-grid__column-medium-6 l-grid__column-large-4 c-azde-navigation__teaser__wrapper">
                                    <div class="js-azde-navigation__teaser c-azde-navigation__teaser  js-agency-licence-hide-parent">
                                      <div class="c-azde-navigation__teaser__image__wrapper ">
                                        <picture class="cmp-image c-image  c-azde-navigation__teaser__image ">
                                          <!--<img src="/etc.clientlibs/onemarketing/platform/clientlibs/aem-core/resources/images/1px.gif" srcset="/content/experience-fragments/onemarketing/azde/azd/de_DE/azde_navigation/allianz-de-navigation/allianz-de-navigation/_jcr_content/root/navigation/navigation-topic-parsys/navigation_topic_1660317978/navigation-teaser-parsys/navigation_teaser_1754122512/teaser-image.img.60.320.jpeg/1557215211464/tkv-flyout.jpeg 320w,/content/experience-fragments/onemarketing/azde/azd/de_DE/azde_navigation/allianz-de-navigation/allianz-de-navigation/_jcr_content/root/navigation/navigation-topic-parsys/navigation_topic_1660317978/navigation-teaser-parsys/navigation_teaser_1754122512/teaser-image.img.60.640.jpeg/1557215211464/tkv-flyout.jpeg 640w,/content/experience-fragments/onemarketing/azde/azd/de_DE/azde_navigation/allianz-de-navigation/allianz-de-navigation/_jcr_content/root/navigation/navigation-topic-parsys/navigation_topic_1660317978/navigation-teaser-parsys/navigation_teaser_1754122512/teaser-image.img.60.768.jpeg/1557215211464/tkv-flyout.jpeg 768w,/content/experience-fragments/onemarketing/azde/azd/de_DE/azde_navigation/allianz-de-navigation/allianz-de-navigation/_jcr_content/root/navigation/navigation-topic-parsys/navigation_topic_1660317978/navigation-teaser-parsys/navigation_teaser_1754122512/teaser-image.img.60.1280.jpeg/1557215211464/tkv-flyout.jpeg 1280w,/content/experience-fragments/onemarketing/azde/azd/de_DE/azde_navigation/allianz-de-navigation/allianz-de-navigation/_jcr_content/root/navigation/navigation-topic-parsys/navigation_topic_1660317978/navigation-teaser-parsys/navigation_teaser_1754122512/teaser-image.img.60.1920.jpeg/1557215211464/tkv-flyout.jpeg 1920w,/content/experience-fragments/onemarketing/azde/azd/de_DE/azde_navigation/allianz-de-navigation/allianz-de-navigation/_jcr_content/root/navigation/navigation-topic-parsys/navigation_topic_1660317978/navigation-teaser-parsys/navigation_teaser_1754122512/teaser-image.img.60.3360.jpeg/1557215211464/tkv-flyout.jpeg 3360w" alt="Tierkrankenversicherung Allianz - Kranker Hund" sizes="258px" data-component-id="root/navigation/navigation-topic-parsys/navigation_topic_1660317978/navigation-teaser-parsys/navigation_teaser_1754122512/teaser-image" class="c-image__img c-azde-navigation__teaser__image__img c-teaser__image-img">-->
                                        </picture>
                                      </div>
                                      <div class="c-azde-navigation__teaser__content">
                                        <span class="c-heading  c-heading--subsection-xsmall c-azde-navigation__teaser__headline c-link--capitalize u-text-hyphen-auto">
                                          Tierkrankenversicherung
                                        </span>
                                        <div class="c-copy u-text-hyphen-auto">
                                          Schutz für Ihren vierbeinigen Gefährten.
                                        </div>
                                        <div class="c-azde-navigation__teaser__bottom">
                                          <a class="c-link c-link--block" href="https://www.allianz.de/gesundheit/tierkrankenversicherung/" target="_self" data-link-title="Mehr erfahren" aria-label="Mehr erfahren" data-component-id="root/navigation/navigation-topic-parsys/navigation_topic_1660317978/navigation-teaser-parsys/navigation_teaser_1754122512/teaser-link">
                                            <span aria-hidden="true" class="c-link__icon c-icon c-icon--arrow-right"></span>
                                            <span class="c-link__text">Mehr erfahren</span>
                                          </a>
                                        </div>
                                      </div>
                                    </div>
                                  </div>
                                </div>
                              </div>
                            </div>
                          </li>
                          <li class="c-azde-navigation__topic c-azde-navigation__topic__tablet-group-element">
                            <span class="c-azde-navigation__topic__title js-azde-navigation__topic__title--tablet-group" aria-expanded="false" role="button" tabindex="-1">
                              Vorsorge &amp; Test
                              <span class="c-icon c-icon--chevron-down c-azde-navigation__topic__title__icon" aria-hidden="true"></span>
                            </span>
                            <div class="c-azde-navigation__topic__list" style="height: 0px;">
                              <div class="l-grid l-grid--max-width">
                                <div class="l-grid__row c-azde-navigation__topic__list__row" role="group" aria-label="Vorsorge &amp; Vermögen">
                                </div>
                                <div class="l-grid__row c-azde-navigation__topic__teasers-row c-azde-navigation__topic__teasers-row--two-teasers-size">
                                  <div class="l-grid__column-medium-6 l-grid__column-large-4 c-azde-navigation__teaser__wrapper">
                                    <div class="js-azde-navigation__teaser c-azde-navigation__teaser  js-agency-licence-hide-parent">
                                      <div class="c-azde-navigation__teaser__image__wrapper ">
                                        <picture class="cmp-image c-image  c-azde-navigation__teaser__image ">
                                          <!--<img src="/etc.clientlibs/onemarketing/platform/clientlibs/aem-core/resources/images/1px.gif" srcset="/content/experience-fragments/onemarketing/azde/azd/de_DE/azde_navigation/allianz-de-navigation/allianz-de-navigation/_jcr_content/root/navigation/navigation-topic-parsys/navigation_topic_810605062/navigation-teaser-parsys/navigation_teaser/teaser-image.img.60.320.jpeg/1576741091619/bu-keyvisual-bearb-junge-frau-nachdenklich.jpeg 320w,/content/experience-fragments/onemarketing/azde/azd/de_DE/azde_navigation/allianz-de-navigation/allianz-de-navigation/_jcr_content/root/navigation/navigation-topic-parsys/navigation_topic_810605062/navigation-teaser-parsys/navigation_teaser/teaser-image.img.60.640.jpeg/1576741091619/bu-keyvisual-bearb-junge-frau-nachdenklich.jpeg 640w,/content/experience-fragments/onemarketing/azde/azd/de_DE/azde_navigation/allianz-de-navigation/allianz-de-navigation/_jcr_content/root/navigation/navigation-topic-parsys/navigation_topic_810605062/navigation-teaser-parsys/navigation_teaser/teaser-image.img.60.768.jpeg/1576741091619/bu-keyvisual-bearb-junge-frau-nachdenklich.jpeg 768w,/content/experience-fragments/onemarketing/azde/azd/de_DE/azde_navigation/allianz-de-navigation/allianz-de-navigation/_jcr_content/root/navigation/navigation-topic-parsys/navigation_topic_810605062/navigation-teaser-parsys/navigation_teaser/teaser-image.img.60.1280.jpeg/1576741091619/bu-keyvisual-bearb-junge-frau-nachdenklich.jpeg 1280w,/content/experience-fragments/onemarketing/azde/azd/de_DE/azde_navigation/allianz-de-navigation/allianz-de-navigation/_jcr_content/root/navigation/navigation-topic-parsys/navigation_topic_810605062/navigation-teaser-parsys/navigation_teaser/teaser-image.img.60.1920.jpeg/1576741091619/bu-keyvisual-bearb-junge-frau-nachdenklich.jpeg 1920w,/content/experience-fragments/onemarketing/azde/azd/de_DE/azde_navigation/allianz-de-navigation/allianz-de-navigation/_jcr_content/root/navigation/navigation-topic-parsys/navigation_topic_810605062/navigation-teaser-parsys/navigation_teaser/teaser-image.img.60.3360.jpeg/1576741091619/bu-keyvisual-bearb-junge-frau-nachdenklich.jpeg 3360w" alt="Berufsunfähigkeitsversicherung Allianz - Frau denkt über Zukunft nach" sizes="258px" data-component-id="root/navigation/navigation-topic-parsys/navigation_topic_810605062/navigation-teaser-parsys/navigation_teaser/teaser-image" class="c-image__img c-azde-navigation__teaser__image__img c-teaser__image-img">-->
                                        </picture>
                                      </div>
                                      <div class="c-azde-navigation__teaser__content">
                                        <span class="c-heading  c-heading--subsection-xsmall c-azde-navigation__teaser__headline c-link--capitalize u-text-hyphen-auto">
                                          Berufsunfähigkeits versicherung
                                        </span>
                                        <div class="c-copy u-text-hyphen-auto">
                                          Wichtiger als Du denkst
                                        </div>
                                        <div class="c-azde-navigation__teaser__bottom">
                                          <a class="c-link c-link--block" href="https://www.allianz.de/vorsorge/berufsunfaehigkeitsversicherung/" target="_self" data-link-title="Mehr erfahren" aria-label="Mehr erfahren" data-component-id="root/navigation/navigation-topic-parsys/navigation_topic_810605062/navigation-teaser-parsys/navigation_teaser/teaser-link">
                                            <span aria-hidden="true" class="c-link__icon c-icon c-icon--arrow-right"></span>
                                            <span class="c-link__text">Mehr erfahren</span>
                                          </a>
                                        </div>
                                      </div>
                                    </div>
                                  </div>
                                  <div class="l-grid__column-medium-6 l-grid__column-large-4 c-azde-navigation__teaser__wrapper">
                                    <div class="js-azde-navigation__teaser c-azde-navigation__teaser  js-agency-licence-hide-parent">
                                      <div class="c-azde-navigation__teaser__image__wrapper ">
                                        <picture class="cmp-image c-image  c-azde-navigation__teaser__image ">
                                          <!--<img src="/etc.clientlibs/onemarketing/platform/clientlibs/aem-core/resources/images/1px.gif" srcset="/content/experience-fragments/onemarketing/azde/azd/de_DE/azde_navigation/allianz-de-navigation/allianz-de-navigation/_jcr_content/root/navigation/navigation-topic-parsys/navigation_topic_810605062/navigation-teaser-parsys/navigation_teaser_348739592/teaser-image.img.60.320.jpeg/1558510537287/baby-auf-arm-bis-03-2021.jpeg 320w,/content/experience-fragments/onemarketing/azde/azd/de_DE/azde_navigation/allianz-de-navigation/allianz-de-navigation/_jcr_content/root/navigation/navigation-topic-parsys/navigation_topic_810605062/navigation-teaser-parsys/navigation_teaser_348739592/teaser-image.img.60.640.jpeg/1558510537287/baby-auf-arm-bis-03-2021.jpeg 640w,/content/experience-fragments/onemarketing/azde/azd/de_DE/azde_navigation/allianz-de-navigation/allianz-de-navigation/_jcr_content/root/navigation/navigation-topic-parsys/navigation_topic_810605062/navigation-teaser-parsys/navigation_teaser_348739592/teaser-image.img.60.768.jpeg/1558510537287/baby-auf-arm-bis-03-2021.jpeg 768w,/content/experience-fragments/onemarketing/azde/azd/de_DE/azde_navigation/allianz-de-navigation/allianz-de-navigation/_jcr_content/root/navigation/navigation-topic-parsys/navigation_topic_810605062/navigation-teaser-parsys/navigation_teaser_348739592/teaser-image.img.60.1280.jpeg/1558510537287/baby-auf-arm-bis-03-2021.jpeg 1280w,/content/experience-fragments/onemarketing/azde/azd/de_DE/azde_navigation/allianz-de-navigation/allianz-de-navigation/_jcr_content/root/navigation/navigation-topic-parsys/navigation_topic_810605062/navigation-teaser-parsys/navigation_teaser_348739592/teaser-image.img.60.1920.jpeg/1558510537287/baby-auf-arm-bis-03-2021.jpeg 1920w,/content/experience-fragments/onemarketing/azde/azd/de_DE/azde_navigation/allianz-de-navigation/allianz-de-navigation/_jcr_content/root/navigation/navigation-topic-parsys/navigation_topic_810605062/navigation-teaser-parsys/navigation_teaser_348739592/teaser-image.img.60.3360.jpeg/1558510537287/baby-auf-arm-bis-03-2021.jpeg 3360w" alt="Risikolebensversicherung Allianz - Baby schläft sicher " sizes="258px" data-component-id="root/navigation/navigation-topic-parsys/navigation_topic_810605062/navigation-teaser-parsys/navigation_teaser_348739592/teaser-image" class="c-image__img c-azde-navigation__teaser__image__img c-teaser__image-img">-->
                                        </picture>
                                      </div>
                                      <div class="c-azde-navigation__teaser__content">
                                        <span class="c-heading  c-heading--subsection-xsmall c-azde-navigation__teaser__headline c-link--capitalize u-text-hyphen-auto">
                                          Risikolebens versicherung
                                        </span>
                                        <div class="c-copy u-text-hyphen-auto">
                                          Individueller Schutz für Ihre Familie.
                                        </div>
                                        <div class="c-azde-navigation__teaser__bottom">
                                          <a class="c-link c-link--block" href="https://www.allianz.de/vorsorge/risikolebensversicherung/" target="_self" data-link-title="Mehr erfahren" aria-label="Mehr erfahren" data-component-id="root/navigation/navigation-topic-parsys/navigation_topic_810605062/navigation-teaser-parsys/navigation_teaser_348739592/teaser-link">
                                            <span aria-hidden="true" class="c-link__icon c-icon c-icon--arrow-right"></span>
                                            <span class="c-link__text">Mehr erfahren</span>
                                          </a>
                                        </div>
                                      </div>
                                    </div>
                                  </div>
                                </div>
                              </div>
                            </div>
                          </li>
                          <li class="c-azde-navigation__list__separator" role="separator"></li>
                          <li class="c-azde-navigation__topic">
                            <span class="c-azde-navigation__topic__title" aria-expanded="false" role="button" tabindex="-1">
                              Beratung
                              <span class="c-icon c-icon--chevron-down c-azde-navigation__topic__title__icon" aria-hidden="true"></span>
                            </span>
                            <div class="c-azde-navigation__topic__list" style="height: 0px;">
                              <div class="l-grid l-grid--max-width">
                                <div class="l-grid__row c-azde-navigation__topic__list__row" role="group" aria-label="Beratung">
                                </div>
                                <div class="l-grid__row c-azde-navigation__topic__teasers-row c-azde-navigation__topic__teasers-row--two-teasers-size">
                                  <div class="l-grid__column-medium-6 l-grid__column-large-4 c-azde-navigation__teaser__wrapper">
                                    <div class="js-azde-navigation__teaser c-azde-navigation__teaser  js-agency-licence-hide-parent">
                                      <div class="c-azde-navigation__teaser__image__wrapper ">
                                      </div>
                                      <div class="c-azde-navigation__teaser__content">
                                        <span class="c-heading  c-heading--subsection-xsmall c-azde-navigation__teaser__headline c-link--capitalize u-text-hyphen-auto">
                                          Produktfinder
                                        </span>
                                        <div class="c-copy u-text-hyphen-auto">
                                          Finden Sie jetzt das passende Produkt.
                                        </div>
                                        <div class="c-azde-navigation__teaser__bottom">
                                          <a class="c-link c-link--block" href="https://www.allianz.de/produktuebersicht/" target="_self" data-link-title="Produkt finden" aria-label="Produkt finden" data-component-id="root/navigation/navigation-topic-parsys/navigation_topic_1919100363/navigation-teaser-parsys/navigation_teaser_17_1309550178/teaser-link">
                                            <span aria-hidden="true" class="c-link__icon c-icon c-icon--arrow-right"></span>
                                            <span class="c-link__text">Produkt finden</span>
                                          </a>
                                        </div>
                                      </div>
                                    </div>
                                  </div>
                                  <div class="l-grid__column-medium-6 l-grid__column-large-4 c-azde-navigation__teaser__wrapper">
                                    <div class="js-azde-navigation__teaser c-azde-navigation__teaser  js-agency-licence-hide-parent">
                                      <div class="c-azde-navigation__teaser__image__wrapper ">
                                      </div>
                                      <div class="c-azde-navigation__teaser__content">
                                        <span class="c-heading  c-heading--subsection-xsmall c-azde-navigation__teaser__headline c-link--capitalize u-text-hyphen-auto">
                                          Servicecenter
                                        </span>
                                        <div class="c-copy     u-text-hyphen-auto">
                                          Melden Sie uns jetzt Ihr Anliegen.
                                        </div>
                                        <div class="c-azde-navigation__teaser__bottom">
                                          <a class="c-link c-link--block     " href="https://www.allianz.de/service/" target="_self" data-link-title="Kontakt aufnehmen" aria-label="Kontakt aufnehmen" data-component-id="root/navigation/navigation-topic-parsys/navigation_topic_1919100363/navigation-teaser-parsys/navigation_teaser_17/teaser-link">
                                            <span aria-hidden="true" class="c-link__icon c-icon c-icon--arrow-right"></span>
                                            <span class="c-link__text">Kontakt aufnehmen</span>
                                          </a>
                                        </div>
                                      </div>
                                    </div>
                                  </div>
                                </div>
                              </div>
                            </div>
                          </li>
                          <li class="c-azde-navigation__topic">
                            <span class="c-azde-navigation__topic__title" aria-expanded="false" role="button" tabindex="-1">
                              Meine Allianz &amp; Services
                              <span class="c-icon c-icon--chevron-down c-azde-navigation__topic__title__icon" aria-hidden="true"></span>
                            </span>
                            <div class="c-azde-navigation__topic__list" style="height: 0px;">
                              <div class="l-grid l-grid--max-width">
                                <div class="l-grid__row c-azde-navigation__topic__list__row" role="group" aria-label="Meine Allianz &amp; Services">
                                  <div class="l-grid__column-medium-6 l-grid__column-large-3 c-azde-navigation__topic__teasers-column">
                                    <div class="l-grid__column-medium-6 l-grid__column-large-4 c-azde-navigation__teaser__wrapper">
                                      <div class="js-azde-navigation__teaser c-azde-navigation__teaser  js-agency-licence-hide-parent">
                                        <div class="c-azde-navigation__teaser__image__wrapper c-azde-navigation__teaser__image__wrapper--no-image">
                                        </div>
                                        <div class="c-azde-navigation__teaser__content">
                                          <span class="c-heading  c-heading--subsection-xsmall c-azde-navigation__teaser__headline c-link--capitalize u-text-hyphen-auto">
                                            E-Mail statt Brief
                                          </span>
                                          <div class="c-copy     u-text-hyphen-auto">
                                            Gemeinsam für unsere einzigartigen Lebensräume.
                                          </div>
                                          <div class="c-azde-navigation__teaser__bottom">
                                            <a class="c-link c-link--block     " href="https://www.allianz.de/service/email/" target="_self" data-link-title="Mehr Erfahren" aria-label="Mehr Erfahren" data-component-id="root/navigation/navigation-topic-parsys/navigation_topic_485894667/navigation-teaser-parsys/navigation_teaser_17/teaser-link">
                                              <span aria-hidden="true" class="c-link__icon c-icon c-icon--arrow-right"></span>
                                              <span class="c-link__text">Mehr Erfahren</span>
                                            </a>
                                          </div>
                                        </div>
                                      </div>
                                    </div>
                                    <div class="l-grid__column-medium-6 l-grid__column-large-4 c-azde-navigation__teaser__wrapper">
                                      <div class="js-azde-navigation__teaser c-azde-navigation__teaser  js-agency-licence-hide-parent">
                                        <div class="c-azde-navigation__teaser__image__wrapper c-azde-navigation__teaser__image__wrapper--no-image">
                                        </div>
                                        <div class="c-azde-navigation__teaser__content">
                                          <span class="c-heading  c-heading--subsection-xsmall c-azde-navigation__teaser__headline c-link--capitalize u-text-hyphen-auto">
                                            Vorteilsprogramm
                                          </span>
                                          <div class="c-copy     u-text-hyphen-auto">
                                            Unser Dankeschön für Ihre Treue – sichern Sie sich gratis Ihr persönliches Jahresgeschenk.
                                          </div>
                                          <div class="c-azde-navigation__teaser__bottom">
                                            <a class="c-link c-link--block     " href="https://www.allianz.de/service/vorteilsprogramm/" target="_self" data-link-title="Mehr Erfahren" aria-label="Mehr Erfahren" data-component-id="root/navigation/navigation-topic-parsys/navigation_topic_485894667/navigation-teaser-parsys/navigation_teaser_1744703235/teaser-link">
                                              <span aria-hidden="true" class="c-link__icon c-icon c-icon--arrow-right"></span>
                                              <span class="c-link__text">Mehr Erfahren</span>
                                            </a>
                                          </div>
                                        </div>
                                      </div>
                                    </div>
                                  </div>
                                </div>
                              </div>
                            </div>
                          </li>
                        </ul>
                      </nav>
                      </div>
                    </div>
                  </div>
                  <div class="c-azde-header__login-profile__mobile-placeholder">
                  </div>
                  <div class="c-azde-header__metabar__mobile-placeholder">
                  </div>
                </div>
              </div>
              <div class="c-azde-header__phone-mobile-flyout">
                <p class="c-copy c-azde-header__phone-mobile-flyout__phone-text"></p>
                <a href="tel:" class="c-button c-button--secondary c-azde-header__phone-mobile-flyout__phone-button">
                </a>
                <p class="c-copy c-azde-header__phone-mobile-flyout__link-text"></p>
                <a class="c-link c-link--block" href="#">
                  <span class="c-link__text"></span>
                </a>
              </div>
              <div id="header-search" class="c-azde-header__search-form-flyout" aria-hidden="true">
                <div class="experience-fragment-page xfpage page basicpage">
                  <div class="aem-Grid aem-Grid--12 aem-Grid--default--12 ">
                    <div class="search-form container aem-GridColumn aem-GridColumn--default--12">
                      <div class="c-search-form c-azde-search-form js-search-form js-azde-search-form" data-autosuggestion-url="https://search.allianz.de/api/apps/oma_azde/query/qps_oma_azde" data-autosuggestion-number-of-results-header="5" data-autosuggestion-number-of-results-footer="2" data-autosuggestion-number-of-results-other="5" data-autosuggestion-division-ctx="complete" data-autosuggestion-content-area-ctx="private">
                        <div class="l-grid l-grid--max-width">
                          <div class="l-grid__row justify-content-center">
                            <div class="l-grid__column-large-8 l-grid__column-medium-12 l-grid__column-small-12" itemscope="" itemtype="http://schema.org/WebSite">
                              <form action="https://www.allianz.de/suche/#/search" method="GET" itemprop="potentialAction" itemscope="" itemtype="http://schema.org/SearchAction" class="js-search-form__form">
                                <div class="c-search-form__content">
                                  <div class="c-search-form__search-icon"><i aria-hidden="true" class="c-icon c-icon--search"></i></div>
                                  <div class="c-search-form__input-holder">
                                    <span class="c-search-form__close-icon js-search-form__close-icon c-icon c-icon--close u-hidden"></span>
                                  </div>
                                  <div class="c-search-form__actions">
                                    <button class="c-button c-search-form__button">
                                      Suchen
                                    </button>
                                    <button class="c-button c-button--icon c-button--solo-icon c-button--small c-search-form__button--parsys">
                                      <span class="c-button__icon c-icon c-icon--search"></span>
                                    </button>
                                  </div>
                                </div>
                                <div class="c-search-form__suggestion js-search-form__suggestion">
                                  <div class="c-search-form__suggestion-directlink">
                                    <p class="c-copy u-margin-bottom-s">Service</p>
                                    <div class="c-search-form__suggestion-link-row">
                                    </div>
                                  </div>
                                  <div class="c-search-form__suggestion-links">
                                    <p class="c-copy u-margin-bottom-sm">Suchvorschläge</p>
                                    <div class="c-search-form__suggestion-link-row">
                                    </div>
                                  </div>
                                </div>
                              </form>
                            </div>
                          </div>
                        </div>
                      </div>
                    </div>
                  </div>
                </div>
              </div>
            </header>
          </div>
        </div>
      </div>
    </div>
    <!-- HERO -->
    <div class="stage container aem-GridColumn aem-GridColumn--default--12">
      <div class="c-stage c-stage--content-page c-stage--1by1dot4-ratio c-stage--theme-c-breadcrumb--negative" style="background-color:transparent;">
        <div class="c-stage__wrapper">
          <div class="c-stage__image-container">
            <div class="c-stage__overlay" data-overlay-style="dark" data-overlay-type="gradient" data-gradient-position="top" data-gradient-final-position="50" data-gradient-opacity="70" style="background: linear-gradient(rgba(0, 0, 0, 0.7) 0%, rgba(0, 0, 0, 0) 50%);"></div>
            <picture class="cmp-image c-image  c-stage__image c-stage__image--cover ">
              <xsl:apply-templates select="picture"/>
            </picture>
            <div class="l-grid l-grid--max-width c-stage__promotional-element u-hidden-small-down">
              <div class="c-promotional-element c-promotional-element--circle c-promotional-element--style-2b c-promotional-element--top-left" style="background-color:transparent;color: ;">
                <div class="c-promotional-element--infopoint">
                </div>
                <div class="c-promotional-element__inner">
                </div>
              </div>
            </div>
          </div>
          <div class="l-grid l-grid--max-width c-stage__content">
            <div class="l-grid__row c-stage__content__grid">
              <div class="l-grid__column-large-8 offset-large-2 l-grid__column-medium-10 offset-medium-1">
                <div>
                  <xsl:apply-templates select="strapline"/>
                </div>
              </div>
              <div class="l-grid__column-large-10 offset-large-1">
                <div>
                  <xsl:apply-templates select="headline"/>
                </div>
              </div>
              <div class="l-grid__column-medium-10 offset-medium-1 l-grid__column-large-8 offset-large-2">
                <div class="u-hidden-medium-up c-stage__promotional-element c-stage__promotional-element--mobile-view">
                  <div class="c-promotional-element c-promotional-element--circle c-promotional-element--style-2b c-promotional-element--top-left" style="background-color:transparent;color: ;">
                    <div class="c-promotional-element--infopoint">
                    </div>
                    <div class="c-promotional-element__inner">
                    </div>
                  </div>
                </div>
              </div>
              <div class="l-grid__column-medium-8 offset-medium-2 c-stage__button__grid">
                <div>
                  <a href="https://www.allianz.de/vorsorge/schatzbrief/rechner/" target="_self" id="Content_LeadIn::Button::Jetzt-berechnen" aria-label="Jetzt berechnen" class=" c-button     c-button--direct-emphasis  c-button--link c-button-link-center-align" data-component-id="root/stage/button">
                    Jetzt berechnen
                  </a>
                </div>
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>

    <!-- Footer -->
    <div class="in-page-navigation aem-GridColumn aem-GridColumn--default--12"><div aria-label="In Page Navigation" class="pl-container l-container--full-width c-in-page-navigation u-hidden-print">
      <div class="l-container">
        <div class="l-grid--max-width">
          <div class="l-grid__row">
            <div class="l-grid__column-12 c-in-page-navigation__container">
              <div class="aem-Grid aem-Grid--12 aem-Grid--default--12 ">
                <div class="in-page-navigation-title responsivegrid aem-GridColumn aem-GridColumn--default--12">
                  <span class="c-heading c-heading--subsection-xsmall">Das finden Sie hier</span>
                </div>
              </div>
              <div class="c-in-page-navigation__list-items" role="navigation">
                <div class="swiper-container js-in-page-nav-carousel swiper-container-horizontal swiper-container-free-mode" data-published="">
                  <ul class="swiper-wrapper" style="transition-duration: 0ms; transform: translate3d(0px, 0px, 0px);">
                    <li class="c-in-page-navigation__list-items__active-line" style="width: 190.469px; left: 0px;">
                    </li>
                    <li class="swiper-slide" data-index="0">
                      <a data-hash="leistungen-schatzbrief" href="#leistungen-schatzbrief" class="c-link c-link--no-text-transform">Leistungen im Überblick</a>
                    </li>

                    <li class="swiper-slide" data-index="1">
                      <a data-hash="vorteile-schatzbrief" href="#vorteile-schatzbrief" class="c-link c-link--no-text-transform">Vorteile des SchatzBriefs</a>
                    </li>

                    <li class="swiper-slide" data-index="2">
                      <a data-hash="merkmale-tabelle" href="#merkmale-tabelle" class="c-link c-link--no-text-transform">Tabelle der Produktmerkmale</a>
                    </li>

                    <li class="swiper-slide" data-index="3">
                      <a data-hash="vorteile-staerken-allianz" href="#vorteile-staerken-allianz" class="c-link c-link--no-text-transform">Stärken der Allianz</a>
                    </li>

                    <li class="swiper-slide" data-index="4">
                      <a data-hash="vorsorgekonzepte-schatzbrief" href="#vorsorgekonzepte-schatzbrief" class="c-link c-link--no-text-transform">Vorsorgekonzepte zur Wahl</a>
                    </li>

                    <li class="swiper-slide" data-index="5">
                      <a data-hash="haeufige-fragen-schatzbrief" href="#haeufige-fragen-schatzbrief" class="c-link c-link--no-text-transform">Häufige Fragen</a>
                    </li>
                  </ul>
                  <span class="swiper-notification" aria-live="assertive" aria-atomic="true"></span></div>

              </div>
            </div>
          </div>
        </div>
      </div>
    </div>

      <div class="c-in-page-navigation__placeholder u-hidden"></div>
    </div>
  </xsl:template>

  <!-- ### ELEMENT MATCH ###-->
  <!-- -->
  <xsl:template match="picture[@xlink:href]">
    <a>
      <div class="js-tile-media c-flexible-tile__icon__wrapper">
        <div  aria-hidden="true">
          <xsl:copy-of select="svtx:getImageElementOfHref(@xlink:href, 'master')"/>
        </div>
      </div>
    </a>
  </xsl:template>

  <xsl:template match="strapline">
    <span class="c-heading  c-heading--subsection-medium c-stage__topline c-link--capitalize u-text-hyphen-auto">
      <div style="text-align: center;"><span style="color: rgb(255,255,255);"><xsl:apply-templates/></span></div>
    </span>
  </xsl:template>

  <xsl:template match="headline">
    <h1 class="c-heading  c-heading--page c-heading--page c-stage__headline c-link--capitalize u-text-hyphen-auto">
      <div style="text-align: center;"><span style="color: rgb(255,255,255);"><xsl:apply-templates/></span></div>
    </h1>
  </xsl:template>

  <xsl:template match="item">
    <xsl:if test="position() lt 4">
      <div class="l-grid__column-large-4 l-grid__column-medium-4 c-carousel__three-column__slide c-tile__product-tile--slide c-flexible-tile__slide">
        <div class="flexible-tile container">
          <div class="js-tile-item js-default-component c-flexible-tile c-flexible-tile--with-icon" id="c-flexible-tile1760489507" data-is-init="true">
            <xsl:apply-templates select="picture"/>
            <span class="c-unformatted-text">
              Lorem Ipsum
            </span>
            <xsl:apply-templates select="paragraph"/>
            <div class="js-tile-cta c-flexible-tile__bottom" style="margin-bottom: 0px; margin-top: auto;">
            </div>
          </div>
        </div>
      </div>
    </xsl:if>
  </xsl:template>

  <xsl:template match="body">
    <xsl:apply-templates select="bullet-list"/>
  </xsl:template>

  <xsl:template match="bullet-list">
    <xsl:apply-templates/>
  </xsl:template>

  <xsl:template match="bold">
    <strong><xsl:apply-templates/></strong>
  </xsl:template>

  <xsl:template match="paragraph">
    <div class="c-copy c-flexible-tile__text u-text-center  u-text-hyphen-auto">
      <xsl:apply-templates/>
    </div>
  </xsl:template>

  <!-- -->
  <xsl:function name="svtx:getCheckedOutAsset" as="element(asset)?">
    <xsl:param name="asset" as="element(asset)?"/>
    <xsl:copy-of select="if (exists($asset) and $asset/@checked_out_by) then cs:get-asset($asset/@id, 0, -2) else $asset"/>
  </xsl:function>

  <!-- -->
  <xsl:function name="svtx:getCheckedOutMasterStorage" as="element(storage_item)?">
    <xsl:param name="asset" as="element(asset)?"/>
    <xsl:variable name="checkedOutAsset" select="svtx:getCheckedOutAsset($asset)"/>
    <xsl:copy-of select="$checkedOutAsset/storage_item[@key='master']"/>
  </xsl:function>

  <!-- -->
  <xsl:function name="svtx:getImageElementOfHref" as="element(img)?">
    <xsl:param name="href" as="xs:string"/>
    <xsl:param name="storageKey" as="xs:string"/>
    <xsl:variable name="assetID" select="tokenize(substring-after($href, '/asset/id/'), '/')[1]"/>
    <xsl:if test="$assetID">
      <xsl:variable name="assetVersion" select="substring-before(substring-after($href, '/version/'), '/')"/>
      <xsl:variable name="asset" select="if ($assetVersion) then cs:get-asset(xs:integer($assetID), xs:integer($assetVersion)) else cs:get-asset(xs:integer($assetID))"/>
      <xsl:variable name="storageItem" select="$asset/storage_item[@key=$storageKey]"/>
      <img src="{concat($urlPrefix, 'assets/asset/id/', $storageItem/@asset_id, '/storage/', $storageKey, '/file/', tokenize($storageItem/@relpath,'/')[last()])}" style="background: #006192;padding: 1rem;" alt="{$asset/@name}" title="{$asset/@name}" class="c-image__img"/>
    </xsl:if>
  </xsl:function>
</xsl:stylesheet>
