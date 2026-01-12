# SQL Injection with XML and filter bypass

xml = "
  <?xml version='1.0' encoding='UTF-8'?>
    <stockCheck>
      <productId>1</productId>
      <storeId>2</storeId>
    </stockCheck>"

url_path = "/product/stock"
http_method = "POST"




