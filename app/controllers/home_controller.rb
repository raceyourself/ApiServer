require 'gcm'

class HomeController < AuthedController

  def index
    logger.info CONFIG[:google][:api_key]
    gcm = GCM.new(CONFIG[:google][:api_key])
    #reg_ids = ["APA91bG92cl_Yv55DixCgVPkEfBZMwhq6bBILlITkSykPdlkNq2ozP0LRsAA5J0HfBSzsqvfI6c97HO3m1YDfUPubjQC6ycXa56YGDFL6yW_iW6F9VPSwdLgqVPvngNbaBsTc1AK3ZKBtwU5yYQVpliRRgziukoYGNlAnUPdBAosCuYmgMYb1kE"]
    reg_ids = ["APA91bEMjBx2enJIURlmKe3XEo1_CWbYQEVHacHOCgVFR3KjbE-fBWCzcugMPnwDr0wsWyhmH7bK-dPNSl6bggJtgehsosrhmQBKcN4mJ8OzH4HU9I8HzN_3n-nLAdQVnAEt40y4fWobdOOzz6koJlaos7SYvd686w"]
    options = {data: { title: 'You have been challenged by root', text: 'Kneel before Zod!'}}
    response = gcm.send_notification(reg_ids, options)
    logger.info response
  end
  
end
