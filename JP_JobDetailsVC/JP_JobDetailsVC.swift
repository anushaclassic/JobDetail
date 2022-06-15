//
//  JP_JobDetailsVC.swift
//  JobPortal
//
//  Created by Archana Parmar on 9/14/17.
//  Copyright © 2017 Prince Sojitra. All rights reserved.
//

import UIKit
import AlamofireImage
import MapKit
import MBProgressHUD
import WebKit

protocol DataEnteredDelegate: class {
    func userDidEnterInformation(info: String)
}
class JP_JobDetailsVC: UIViewController,MKMapViewDelegate,CLLocationManagerDelegate{
    
    
    //MARK: - @IBOutlet
    @IBOutlet weak var lblsubTitle: UILabel!
    @IBOutlet weak var lblsub_SubTitle: UILabel!
    @IBOutlet weak var consWebHeight: NSLayoutConstraint!
    @IBOutlet weak var webView = WKWebView()
    @IBOutlet weak var imgFavourite: UIImageView!
    @IBOutlet weak var mapview: MKMapView!
    @IBOutlet weak var lblCompanyname: UILabel!
    @IBOutlet weak var imgLogo: UIImageView!
    // @IBOutlet weak var lblDescription: UILabel!
    @IBOutlet weak var TabBar: UITabBar!
    
    @IBOutlet weak var lblApply: UILabel!
    @IBOutlet weak var lblInterested: UILabel!
    @IBOutlet weak var lblUninterested: UILabel!
    
    @IBOutlet weak var indicator: UIActivityIndicatorView!
    
    //MARK:- Variable
    
    var delegate: DataEnteredDelegate? = nil
    var exter_id: String?
    var externalUrl: String?
    var externalEmail: String?
    var searchModel:A_SearchListModel?
    var check:String = ""
    var hud: MBProgressHUD = MBProgressHUD()
    
    var isFavourite = false
    
    var obj:A_JobDetailsModel?
    // MARK: - UIViewController Life Cycle
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        
        //Set default UI
        self.fnForSetDefaultUI()
    }
    override func viewWillAppear(_ animated: Bool) {
        
        super.viewWillAppear(true)
        self.navigationController?.isNavigationBarHidden = false
        self.tabBarController?.tabBar.isHidden = true
        self.webView?.navigationDelegate = self
        self.webView?.scrollView.showsVerticalScrollIndicator = false
        self.webView?.scrollView.showsHorizontalScrollIndicator = false
        self.webView?.scrollView.isScrollEnabled = true
        self.webView?.allowsLinkPreview = true
        if Constants.APPDELEGATE.isVC is JP_UploadCVVC {
            self.fnToMyCV()
        }
        setHeader(isBackHidden: false, title: NSLocalizedString("A_Job_Details", comment: ""))
        mapview.isHidden = true
        
        lblUninterested.text = NSLocalizedString("A_Uninterested", comment: "")
        lblInterested.text = NSLocalizedString("A_Favourites", comment: "").localizedCapitalized
        lblApply.text = NSLocalizedString("A_Apply", comment: "")
        
        fnJobDetail()
        UserDefaults.standard.setValue(nil, forKey: "BuildFromSearch")
    }
    func fnToMyCV(){
        let iJPBuildCVVC = Constants.STORYBOARD.instantiateViewController(withIdentifier: "JP_MYCVVC") as! JP_MYCVVC
        self.navigationController?.pushViewController(iJPBuildCVVC, animated: true)
        
    }
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .default
    }
    
    override func didReceiveMemoryWarning() {
        
        super.didReceiveMemoryWarning()
        
    }
    
    
    // MARK: - UIViewController Actions & Events
    @IBAction func btnUnInterestedClicked(_ sender: UIButton) {
        
         if ((Utils.regUser?.userId) != nil) {
                   fnDiscardJob()
               } else {
                  if(self.exter_id != nil) {
                       self.delegate?.userDidEnterInformation(info: self.exter_id!)
                   }
                   self.navigationController?.popViewController(animated: true)
               }

        
    }
    
    @IBAction func btnFavouriteClicked(_ sender: UIButton) {
        
        //self.navigationController?.popViewController(animated: true)
        if ((Utils.regUser?.userId) != nil) {
        if isFavourite {
            self.fnGetFavouriteDelete(){
                
                Toast.showAlert(message: NSLocalizedString("A_REMOVE_FAV", comment: ""))
                self.imgFavourite.image = UIImage.init(named: "Favorites-bottom")
                self.isFavourite = false
            }
        } else {
            
            self.fnFavoriteJob(){
                Toast.showAlert(message: NSLocalizedString("A_ADD_FAV", comment: ""))
                self.imgFavourite.image = UIImage.init(named: "star_full")
                self.isFavourite = true
            }
        }
         } else {
                       showSimpleAlert()
                   }
    }
    func showSimpleAlert() {
          
          let alert = UIAlertController(title: "", message: NSLocalizedString("ALERT_FOR_LOGIN", comment: ""),preferredStyle: UIAlertController.Style.alert
          
          )
          alert.addAction(UIAlertAction(title: NSLocalizedString("ALERT_FOR_LOGIN_No", comment: ""), style: UIAlertAction.Style.default, handler: { _ in
              //Cancel Action
          }))
          alert.addAction(UIAlertAction(title: NSLocalizedString("ALERT_FOR_LOGIN_Yes", comment: ""),
                                        style: UIAlertAction.Style.default,
                                        handler: {(_: UIAlertAction!) in
                                          //Login screen
                                        let iLoginVc = Constants.STORYBOARD.instantiateViewController(withIdentifier: "JP_LoginVC") as! JP_LoginVC
                                          iLoginVc.hidesBottomBarWhenPushed = true
                                          self.navigationController?.pushViewController(iLoginVc, animated: false)
                                          
          }))
          self.present(alert, animated: true, completion: nil)
      }

    func openUrl(url: NSString)
         {
             let urlStr = url.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
             let searchURL : NSURL = NSURL(string: urlStr!)!
             print(searchURL)
             UIApplication.shared.openURL(searchURL as URL)
         }
       func openMail(urlString:NSString)
       {
            if let url = URL(string: "mailto:\(urlString)") {
                    UIApplication.shared.openURL(url)
                  }
       }

      @IBAction func btnApplyForClicked(_ sender: UIButton) {
          if ((Utils.regUser?.userId) != nil)
           {
               if externalUrl == "" && externalEmail == ""
               {
                   UserDefaults.standard.set(nil, forKey:"isInterested")
                   self.fnOpenPopup(str:"viewConfirmCV")
               }
               else if externalUrl != ""
               {
                    openUrl(url: externalUrl! as NSString)
               }
               else if externalEmail != ""
               {
                   openMail(urlString: externalEmail! as NSString)
               }
           } else
           {
                  showSimpleAlert()
           }
          
      }
    func fnOpenPopup(str:String) {
        
        var iArrKey = ["",""]
        
        let iJP_SelectCVPopUpVC = Constants.STORYBOARD.instantiateViewController(withIdentifier: "JP_SelectCVPopUpVC") as! JP_SelectCVPopUpVC
        
        iJP_SelectCVPopUpVC.strView = str
        
        iJP_SelectCVPopUpVC.blockDismiss = { (str,_,_) in
            
            if str != ""  {
                if str == "AddToFavourite"
                {
                    
                    self.fnFavoriteJob()
                        {
                            Toast.showAlert(backgroundColor:  UIColor.black.withAlphaComponent(0.8), textColor: Utility.sharedInstance().hexStringToUIColor(hex:Constants.THEMECOLOR), message: NSLocalizedString("A_ADD_FAV", comment: ""))
                    }
                }
                else
                {
                    iArrKey = [str,(self.obj?.externalId)!,"\(self.tabBarController!.selectedIndex)"]
                    
                    let iJPSelectCVPopUpVC = Constants.STORYBOARD.instantiateViewController(withIdentifier: "JP_SelectCVPopUpVC") as! JP_SelectCVPopUpVC
                    iJPSelectCVPopUpVC.strView = "viewCVOption"
                    
                    iJPSelectCVPopUpVC.blockDismiss = {  (str,upload,build) in
                        
                        if str != "" {
                            
                            Constants.APPDELEGATE.arrApply = ["","","\(self.tabBarController!.selectedIndex)"]
                            
                        } else {
                            
                            Constants.APPDELEGATE.arrApply = iArrKey
                            
                            if upload {
                                
                                UserDefaults.standard.setValue("uploadCV", forKey: "BuildFromSearch")
                                
                            } else if build {
                                
                                UserDefaults.standard.setValue("buildCV", forKey: "BuildFromSearch")
                            }
                            
                            if !(Utils.regUser?.cvCreated)! && build {
                                let iJPBuildCVVC = Constants.STORYBOARD.instantiateViewController(withIdentifier: "JP_BuildCVVC") as! JP_BuildCVVC
                                iJPBuildCVVC.isEdit = true
                                self.navigationController?.pushViewController(iJPBuildCVVC, animated: true)
                            } else {
                                let iJPBuildCVVC = Constants.STORYBOARD.instantiateViewController(withIdentifier: "JP_MYCVVC") as! JP_MYCVVC
                                iJPBuildCVVC.hidesBottomBarWhenPushed = false
                                self.navigationController?.pushViewController(iJPBuildCVVC, animated: true)
                                
                            }
                            
                        }
                    }
                    iJPSelectCVPopUpVC.modalPresentationStyle = .custom
                    self.present(iJPSelectCVPopUpVC, animated: true, completion: nil)
                }
                
            }
            
        }
        iJP_SelectCVPopUpVC.view.backgroundColor = UIColor.clear
        iJP_SelectCVPopUpVC.modalPresentationStyle = .custom
        self.present(iJP_SelectCVPopUpVC, animated: true, completion: nil)
        
    }
    // MARK: - UIViewController Others
    
    func fnFavoriteJob(completion: (() -> Swift.Void)? = nil){
        
        let iUser = Utils.regUser?.userId ?? ""
        let id = exter_id ?? ""
        let itoken = Utils.regUser?.token ?? ""
        
        let url =  ObjcKeys.baseURL4 + "applicant/\(iUser)/vacancy/\(id)/favorite"
        
        let headers = [
            
            "content-type": "application/json",
            "X-Device-Id": ObjcKeys.strUDID,
            "X-Access-Token" : itoken,
            "X-User-Id": iUser
            
        ]
        
        WebServiceHelper.callBambergService(WSUrl: url, WSMethod: .post, WSParams: [:], WSHeader: headers, isLoader: true) { (iData, iError) in
            
            if let _ = iData as? String {
                self.fnFavoriteJob(completion:completion)
            } else {
                
                if let error = iError {
                    print("aErrorObj===\(error.description)")
                    print("no data found")
                    
                }  else {
                    
                    if  let iDictResponse = iData as? NSDictionary {
                        //print(iDictResponse)
                        
                        if let iValue = iDictResponse.value(forKey: "success") as? Bool,iValue {
                            
                            completion!()
                            
                        } else {
                            Constants.APPDELEGATE.fnAlert(strMsg:NSLocalizedString("A_ApiError", comment: ""))
                        }
                        
                    }
                }
            }
        }
    }
    
    func fnGetFavouriteDelete(completion: (() -> Swift.Void)? = nil)  {
        
        let iUser = Utils.regUser?.userId ?? ""
        let itoken = Utils.regUser?.token ?? ""
        let Id = exter_id ?? ""
        let url =  ObjcKeys.baseURL4 + "applicant/\(iUser)/vacancy/favorite/\(Id)/delete"
        
        let headers = [
            "content-type": "application/json",
            "X-Device-Id": ObjcKeys.strUDID,
            "X-Access-Token" : itoken,
            "X-User-Id": iUser
        ]
        
        WebServiceHelper.callBambergService(WSUrl: url, WSMethod: .post, WSParams: [:], WSHeader: headers, isLoader: true) { (iData, iError) in
            
            if let _ = iData as? String {
                
                self.fnGetFavouriteDelete(completion:completion)
                
            } else {
                
                if let error = iError
                {
                    print("aErrorObj===\(error.description)")
                    print("no data found")
                    
                }
                else
                {
                    if  let iDictResponse = iData as? NSDictionary {
                        //print(iDictResponse)
                        
                        if let iValue = iDictResponse.value(forKey: "success") as? Bool,iValue
                        {
                            completion!()
                            
                        }
                        else
                        {
                            Constants.APPDELEGATE.fnAlert(strMsg:NSLocalizedString("A_ApiError", comment: ""))
                        }
                    }
                }
            }
        }
    }
    func fnForSetDefaultUI()  {
        
        let jscript = "var meta = document.createElement('meta'); meta.setAttribute('name', 'viewport'); meta.setAttribute('content', 'width=device-width'); document.getElementsByTagName('head')[0].appendChild(meta);"
           self.webView?.evaluateJavaScript(jscript)

    
    }
    
    func fnReceivedNotification(notification: Notification){
        let iJPBuildCVVC = Constants.STORYBOARD.instantiateViewController(withIdentifier: "JP_MYCVVC") as! JP_MYCVVC
        self.navigationController?.pushViewController(iJPBuildCVVC, animated: true)
    }
    
    
    // MARK:- APICalling
    
    
    func fnJobDetail(){
        
        var url : String = ""
        var headers = [String : String]()
        let id = exter_id ?? ""
        
        if ((Utils.regUser?.userId) != nil) {
        let iUser = Utils.regUser?.userId ?? ""
        let itoken = Utils.regUser?.token ?? ""
        url =  ObjcKeys.baseURL4 + "vacancy/\(id)"
        
        headers = [
            
            "content-type": "application/json",
            "X-Device-Id": ObjcKeys.strUDID,
            "X-Access-Token" : itoken,
            "X-User-Id": iUser
            
        ]
        }
        else
        {
           
            url =  ObjcKeys.baseURL4 + "vacancy/\(id)"
            
            headers = [
                "Content-type": "application/json",
                "X-Device-Id":ObjcKeys.strUDID,
                "X-Access-Token" : ObjcKeys.accessToken,
               
            ]
        }
        
        WebServiceHelper.callBambergService(WSUrl: url, WSMethod: .get, WSParams: [:], WSHeader: headers, isLoader: true) { (iData, iError) in
            if let _ = iData as? String {
                
                self.fnJobDetail()
                
            }    else {
                
                if let error = iError {
                    print("aErrorObj===\(error.description)")
                    print("no data found")
                    
                }  else {
                    
              
                    
                    let iDictResponse = iData as? NSDictionary
                    
                    self.obj = A_JobDetailsModel.init(object: iDictResponse)
                    
                    self.indicator.startAnimating()
                    
                    if iDictResponse?.count != 0 {
                        
                        self.showNOInfoAlert(isShow: false)
                        
                        
                        
                        if let url = URL.init(string: self.obj?.companyLogo ?? "") {
                            self.imgLogo.af_setImage(withURL: url)
                        }
                        
                        self.lblCompanyname.text = (self.obj?.companyName ?? "")
                        
                        //  self.lblDescription.text =  self.obj?.description?.html2String ?? ""
                        let headerString = "<header><meta name='viewport' content='width=device-width, initial-scale=1.0, maximum-scale=1.0, minimum-scale=1.0, user-scalable=no'></header>"
                        self.webView?.loadHTMLString(headerString + (self.obj?.description)!, baseURL: nil)
                      //  self.webView?.loadHTMLString((self.obj?.description)!, baseURL: nil)
                        self.lblsubTitle.text = self.obj?.title ?? ""
                        self.lblsub_SubTitle.text = self.obj?.subtitle ?? ""
                        
                        self.isFavourite = self.obj?.favorite ?? false
                        
                        
                        if self.isFavourite {
                            self.imgFavourite.image = UIImage.init(named: "star_full")
                        } else {
                            self.imgFavourite.image = UIImage.init(named: "Favorites-bottom")
                        }
                        
                        if  let position = self.obj?.position  {
                            self.mapview.isHidden = false
                            if   position[0] != 0 &&  position[1] != 0   {
                                
                                let annotation = MKPointAnnotation()
                                let centerCoordinate = CLLocationCoordinate2D.init(latitude: CLLocationDegrees.init(position[1]), longitude: CLLocationDegrees.init(position[0]))
                                
                                annotation.coordinate = centerCoordinate
                                annotation.title = self.obj?.locationName ?? ""
                                
                                self.mapview.addAnnotation(annotation)
                                
                                let region = MKCoordinateRegion(center: centerCoordinate, span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
                                self.mapview.setRegion(region, animated: true)
                            }
                        }
                    } else {
                        self.showNOInfoAlert(isShow: true)
                    }
                }
            }
        }
    }
    
    
    func fnDiscardJob(completion: (() -> Swift.Void)? = nil){
        
        let iUser = Utils.regUser?.userId ?? ""
        let id = exter_id ?? ""
        let itoken = Utils.regUser?.token ?? ""
        
        let url =  ObjcKeys.baseURL4 + "applicant/\(iUser)/vacancy/\(id)/discard"
        
        let headers = [
            "content-type": "application/json",
            "X-Device-Id": ObjcKeys.strUDID,
            "X-Access-Token" : itoken,
            "X-User-Id": iUser
        ]
        
        WebServiceHelper.callBambergService(WSUrl: url, WSMethod: .post, WSParams: [:], WSHeader: headers, isLoader: true) { (iData, iError) in
            
            if let _ = iData as? String {
                self.fnDiscardJob(completion:completion)
            } else {
                
                if let error = iError {
                    print("aErrorObj===\(error.description)")
                    print("no data found")
                    
                }  else {
                    
                    if let iDictResponse = iData as? NSDictionary {
                        //print(iDictResponse)
                        
                        if let iValue = iDictResponse.value(forKey: "success") as? Bool,iValue {
                            
                            if(self.exter_id != nil) {
                                self.delegate?.userDidEnterInformation(info: self.exter_id!)
                            }
                            self.navigationController?.popViewController(animated: true)
                            
                        } else {
                            Constants.APPDELEGATE.fnAlert(strMsg:NSLocalizedString("A_ApiError", comment: ""))
                        }
                    }
                }
            }
        }
    }
}

// MARK: - UITabBar Delegate

extension JP_JobDetailsVC: UITabBarDelegate
{
    
    func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        
        
        switch item.tag {
            
        case 2:
            let iJPSelectCVPopUpVC = Constants.STORYBOARD.instantiateViewController(withIdentifier: "JP_SelectCVPopUpVC") as! JP_SelectCVPopUpVC
            iJPSelectCVPopUpVC.modalPresentationStyle = .custom
            present(iJPSelectCVPopUpVC, animated: true, completion: nil)
            
        default:
            break
        }
    }
}

extension JP_JobDetailsVC: WKNavigationDelegate{
    
    func fnViewHeight(intConstant: CGFloat)  {
        
        self.consWebHeight.constant = intConstant
//        let jscript = "var meta = document.createElement('meta'); meta.setAttribute('name', 'viewport'); meta.setAttribute('content', 'width=device-width'); document.getElementsByTagName('head')[0].appendChild(meta);"
//        self.webView?.evaluateJavaScript(jscript)
        self.webView?.backgroundColor = .black
        self.webView?.layoutIfNeeded()
        self.webView?.setNeedsDisplay()
        self.webView?.setNeedsLayout()
        self.webView?.frame = .zero
    }

    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            self.indicator.stopAnimating()
           webView.evaluateJavaScript("document.body.scrollHeight", completionHandler: { (height, error) in
            self.fnViewHeight(intConstant: height as! CGFloat)
             self.indicator.stopAnimating()
             })
          
        }

     func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        self.indicator.startAnimating()
               
        }
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping ((WKNavigationActionPolicy) -> Void))
    {

        print("webView:\(webView) decidePolicyForNavigationAction:\(navigationAction) decisionHandler:\(decisionHandler)")

        if let requestUrl = navigationAction.request.url {
                print(requestUrl.absoluteString)
             if requestUrl.scheme == "mailto" {
                if(UIApplication.shared.canOpenURL(requestUrl))
                {
                     UIApplication.shared.openURL(requestUrl);
                      return
                 }
               
                }
        }

        decisionHandler(.allow)
    }
    
    
}


