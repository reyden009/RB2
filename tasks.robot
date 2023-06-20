*** Settings ***
Documentation       Orders robots from RobotSpareBin Industries Inc.
...                 Saves the order HTML receipt as a PDF file.
...                 Saves the screenshot of the ordered robot.
...                 Embeds the screenshot of the robot to the PDF receipt.
...                 Creates ZIP archive of the receipts and the images.

Library             RPA.Browser.Selenium    auto_close=${FALSE}
Library             RPA.Excel.Files
Library             RPA.HTTP
Library             RPA.PDF
Library             RPA.Desktop
Library             RPA.Tables
Library             RPA.Archive


*** Tasks ***
Order robots from RobotSpareBin Industries Inc
    Open the intranet website
    Download the Excel file
    Fill the form using the data from the Excel file
    zipmaker
    [Teardown]    Log out and close the browser


*** Keywords ***
Open the intranet website
    Open Available Browser    https://robotsparebinindustries.com/#/robot-order

Close the annoying modal
    Wait Until Page Contains Element    class:alert-buttons
    Click Button    class:btn.btn-dark

Download the Excel file
    Download    https://robotsparebinindustries.com/orders.csv    overwrite=True

Fill and submit the form for one person
    [Arguments]    ${orders}
    Wait Until Page Contains Element    id:head
    Select From List By Value    id:head    ${orders}[Head]
    Input Text    class:form-control    ${orders}[Legs]
    Input Text    id:address    ${orders}[Address]
    Click Button    id:id-body-${orders}[Body]
    Click Button    id:order
    Wait Until Page Contains Element    id:order-completion

Fill the form using the data from the Excel file
    ${orders_s}=    Read table from CSV    orders.csv    header=True
    Close Workbook
    FOR    ${orders}    IN    @{orders_s}
        Close the annoying modal
        Wait Until Keyword Succeeds    3x    1s    Fill and submit the form for one person    ${orders}
#    Fill and submit the form for one person    ${orders}
        Collect the results    ${orders}
        Export the table as a PDF    ${orders}
        Another robot
    END

Collect the results
    [Arguments]    ${orders}
    Screenshot    id:order-completion    ${OUTPUT_DIR}${/}${orders}[Order number].jpg

Export the table as a PDF
    [Arguments]    ${orders}
    Wait Until Element Is Visible    id:order-completion
    ${sales_results_html}=    Get Element Attribute    id:order-completion    outerHTML
    Html To Pdf    ${sales_results_html}    ${OUTPUT_DIR}${/}${orders}[Order number].pdf

Another robot
    Click Button    id:order-another

Log out and close the browser
    Close Browser

zipmaker
    Archive Folder With Zip    ${OUTPUT_DIR}    ${OUTPUT_DIR}${/}zipp.zip    include=*.pdf
