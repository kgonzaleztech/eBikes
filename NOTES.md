
Hi Kelly,

Below are some notes about how I approached solving this assignment. Please let me know if you
have any comments, questions or suggestions.

E-Bikes
Sales Manager (Tom) has requested the following enhancements to the Product Explorer tab:
1. Sales agents have indicated that they regularly need to filter by frame color when speaking with customers during sales calls.
    a. E-Bikes has asked that you add another filter to the product explorer window to allow agents to filter by frame color.
2. Tom would like to be able to see more than the default 9 result cards when searching.
    a. Add a method to allow agents the ability to dynamically change the results per page in the results frame.
3. Many agents have requested the ability to collapse/expand header sections in the product details pane (Electric Components, Frame, Brakes).
    a. Modify the product details component to accommodate this request.
4. Tom mentioned they don’t know whether a bike is in stock until after a sale is completed and they look in a different system. He indicated an API exists to return the in-stock quantity for a given model and asked if that could be incorporated in the product detail page.
    a. Modify the Filter result pane so that when a product card is clicked to display product details the following API is called and the results displayed on the product detail card.
    b. The E-Bikes Backoffice team provided this example API call as reference:
        curl --location --request GET 'https://vpsdevds2-viasat.cs32.force.com/paymentservice/services/apexrest/ebikestockcheck/?pname=DYNAMO+X3' \
            --header 'Accept: application/json' \
            --header 'Content-Type: application/json' \
            --header 'x-api-key: abc123' \
            --header 'Cookie: BrowserId=Jlnf3nImEeumZZ88qOXBuw' \
            --data-raw ''

Step 1
1. I looked to find the component that was handling the filters and I looked at the Product__c object's fields,
next I looked in dev console to see what the data looked like. I found that there was a field called
Frame_Color__c that would be the one to use to filter based on frame color. I added code to filter
by frame color and then I updated the product records and assigned the available colors: red, white, blue and green.

2. I reviewed the code to see how the pagination and card layout was being handled. I decided to put the 
logic in the paginator component so that I could send update event to parent whenever the user
updated the number of items per page using the slider. I used the slider to simplify input validation
and was able to set the max value to the number of products.

3. This was straightforward lwc styling and I looked up accordion and updated the html to allow the sections
to be expanded or collapsed.

4. I tried the curl command in an iterm window to see what the response data looked like. I figured out
there was a currentInventory field that contained the quanity of product available. I went ahead and
added a callout that passed the name of the selected product to the Viasat API and then parsed
the response to extract out the value. If the response wasn't > 1, then updated the html to display 
"Out of stock". Now that I think about it, if the response was 0, I could have displayed the date
it was expected to be back in stock.

5. I wrote a basic unit test for the callout. I used a static resource and uploaded a text file containing
the following input:

{
  "productName" : "DYNAMO X1",
  "nextRestockDate" : "2021-06-06",
  "currentInventory" : 5
}

I tried retrieving the static resource to include in git, but wasn't able to access it since the cloud option in VScode 
isn't available on my machine at the moment and I couldn't find a sfdx retrieve command that would do it.

Thanks for the exercise! I enjoyed doing it as I was able to get time to work on it.

Best,
Karina