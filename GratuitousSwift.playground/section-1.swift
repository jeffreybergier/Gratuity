import UIKit

class GratuitousAnimations: NSObject {
    
    class func GratuitousAnimationDuration() -> Double {
        return 0.5
    }
    
}

class GratuitousColorSelector: NSObject {
    
    class func lightBackgroundColor() -> UIColor {
        return UIColor(red: 185.0/255.0, green: 46.0/255.0, blue: 46.0/255.0, alpha: 1.0)
    }
    
    class func darkBackgroundColor() -> UIColor {
        return UIColor(red: 30.0/255.0, green: 0.0/255.0, blue: 0.0/255.0, alpha: 1.0)
    }
    
    class func lightTextColor() -> UIColor {
        return UIColor(red: 200.0/255.0, green: 0.0/255.0, blue: 0.0/255.0, alpha: 1.0)
    }
    
    class func darkTextColor() -> UIColor {
        return UIColor(red: 104.0/255.0, green: 0.0/255.0, blue: 0.0/255.0, alpha: 1.0)
    }
    
    class func textShadowColor() -> UIColor {
        return UIColor(red: 20.0/255.0, green: 20.0/255.0, blue: 20.0/255.0, alpha: 1.0)
    }
    
}


class GratuitousGradientView: UIView {
    
    internal let gradient = CAGradientLayer()
    var isUpsideDown:Bool = false {
        didSet {
            //self.gradient.colors = [UIColor.clearColor().CGColor, GratuitousColorSelector.darkBackgroundColor().CGColor]
            //self.gradient.colors = [UIColor.clearColor().CGColor, GratuitousColorSelector.lightBackgroundColor().CGColor]
            self.gradient.colors = [UIColor.clearColor().CGColor, UIColor.blackColor().CGColor]
        }
    }
    
    internal override init() {
        super.init()
        self.commonInitializer()
    }
    
    internal required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.commonInitializer()
    }
    
    internal override init(frame: CGRect) {
        super.init(frame: frame)
        self.commonInitializer()
    }
    
    internal func commonInitializer() {
        self.backgroundColor = UIColor.clearColor()
        self.gradient.frame = self.bounds
        self.gradient.colors = [UIColor.blackColor().CGColor, UIColor.clearColor().CGColor]
        //self.gradient.colors = [GratuitousColorSelector.darkBackgroundColor().CGColor, UIColor.clearColor().CGColor]
        //self.gradient.colors = [GratuitousColorSelector.lightBackgroundColor().CGColor, UIColor.clearColor().CGColor]
        self.layer.insertSublayer(self.gradient, atIndex: 0)
    }
    
    override func layoutSubviews() {
        self.gradient.frame = self.bounds
        super.layoutSubviews()
    }
    
}


class BillTableViewCell: UITableViewCell {
    
    @IBOutlet weak internal var billAmountTextLabel: UILabel!
    
    internal var labelTextAttributes = [NSString(): NSObject()]
    var billAmount: NSNumber = Double(0) {
        didSet {
            self.billAmountTextLabel.attributedText = NSAttributedString(string: NSString(format: "$%.0f", self.billAmount.doubleValue), attributes: self.labelTextAttributes)
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        //the default selection styles are so fucking shitty
        self.selectionStyle = UITableViewCellSelectionStyle.None
        
        //configure the colors
        self.contentView.backgroundColor = GratuitousColorSelector.darkBackgroundColor()
        self.billAmountTextLabel.textColor = GratuitousColorSelector.lightTextColor()
        
        //prepare the text attributes to reused over and over
        self.prepareLabelTextAttributes()
    }
    
    internal func prepareLabelTextAttributes() {
        let font = self.billAmountTextLabel.font
        let textColor = self.billAmountTextLabel.textColor
        let text = self.billAmountTextLabel.text
        let shadow = NSShadow()
        shadow.shadowColor = GratuitousColorSelector.textShadowColor()
        shadow.shadowBlurRadius = 1.5
        shadow.shadowOffset = CGSizeMake(0.5, 0.5)
        let attributes = [
            NSForegroundColorAttributeName : textColor,
            NSFontAttributeName : font,
            //NSTextEffectAttributeName : NSTextEffectLetterpressStyle,
            NSShadowAttributeName : shadow
        ]
        self.labelTextAttributes = attributes
        let attributedString = NSAttributedString(string: text!, attributes: self.labelTextAttributes)
        self.billAmountTextLabel.attributedText = attributedString
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        if (selected) {
            UIView.animateWithDuration(GratuitousAnimations.GratuitousAnimationDuration(), animations: { () -> Void in
                self.contentView.backgroundColor = GratuitousColorSelector.lightBackgroundColor()
                self.billAmountTextLabel.textColor = GratuitousColorSelector.darkTextColor()
            })
        } else {
            UIView.animateWithDuration(GratuitousAnimations.GratuitousAnimationDuration(), animations: { () -> Void in
                self.contentView.backgroundColor = GratuitousColorSelector.darkBackgroundColor()
                self.billAmountTextLabel.textColor = GratuitousColorSelector.lightTextColor()
            })
        }
    }
    
}

class TipTableViewCell: UITableViewCell {
    
    @IBOutlet weak internal var tipAmountTextLabel: UILabel!
    
    internal var labelTextAttributes = [NSString(): NSObject()]
    var tipAmount: NSNumber = Double(0) {
        didSet {
            self.tipAmountTextLabel.attributedText = NSAttributedString(string: NSString(format: "$%.0f", self.tipAmount.doubleValue), attributes: self.labelTextAttributes)
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        //the default selection styles are so fucking shitty
        self.selectionStyle = UITableViewCellSelectionStyle.None
        
        //configure the colors
        self.contentView.backgroundColor = GratuitousColorSelector.darkBackgroundColor()
        self.tipAmountTextLabel.textColor = GratuitousColorSelector.lightTextColor()
        
        //prepare the text attributes to reused over and over
        self.prepareLabelTextAttributes()
    }
    
    internal func prepareLabelTextAttributes() {
        let font = self.tipAmountTextLabel.font
        let textColor = self.tipAmountTextLabel.textColor
        let text = self.tipAmountTextLabel.text
        let shadow = NSShadow()
        shadow.shadowColor = GratuitousColorSelector.textShadowColor()
        shadow.shadowBlurRadius = 1.0
        shadow.shadowOffset = CGSizeMake(0.5, 0.5)
        let attributes = [
            NSForegroundColorAttributeName : textColor,
            NSFontAttributeName : font,
            //NSTextEffectAttributeName : NSTextEffectLetterpressStyle,
            NSShadowAttributeName : shadow
        ]
        self.labelTextAttributes = attributes
        let attributedString = NSAttributedString(string: text!, attributes: self.labelTextAttributes)
        self.tipAmountTextLabel.attributedText = attributedString
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        if (selected) {
            UIView.animateWithDuration(GratuitousAnimations.GratuitousAnimationDuration(), animations: { () -> Void in
                self.contentView.backgroundColor = GratuitousColorSelector.lightBackgroundColor()
                self.tipAmountTextLabel.textColor = GratuitousColorSelector.darkTextColor()
            })
        } else {
            UIView.animateWithDuration(GratuitousAnimations.GratuitousAnimationDuration(), animations: { () -> Void in
                self.contentView.backgroundColor = GratuitousColorSelector.darkBackgroundColor()
                self.tipAmountTextLabel.textColor = GratuitousColorSelector.lightTextColor()
            })
        }
    }
    
}



class TipViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak internal var tipPercentageTextLabel: UILabel!
    @IBOutlet weak internal var totalAmountTextLabel: UILabel!
    @IBOutlet weak internal var billAmountTableView: UITableView!
    @IBOutlet weak internal var tipAmountTableView: UITableView!
    @IBOutlet weak var gradientViewUpsideDown: GratuitousGradientView!
    
    internal let MAXBILLAMOUNT = 500
    internal let MAXTIPAMOUNT = 250
    internal let BILLAMOUNTTAG = 0
    internal let TIPAMOUNTTAG = 1
    internal let IDEALTIPPERCENTAGE = 0.2
    
    internal var textSizeAdjustment: NSNumber = NSNumber(double: 0.0)
    internal var billAmountsArray: [NSNumber] = []
    internal var tipAmountsArray: [NSNumber] = []
    internal var totalAmountTextLabelAttributes = [NSString(): NSObject()]
    internal var tipPercentageTextLabelAttributes = [NSString(): NSObject()]
    internal var billAmount: NSNumber = Double(0) {
        didSet {
            self.updateBillAmount(self.billAmount, TipAmount: nil, TipPercentage: nil)
        }
    }
    internal var tipAmount: NSNumber = Double(0) {
        didSet {
            self.updateBillAmount(nil, TipAmount: self.tipAmount, TipPercentage: nil)
        }
    }
    internal var tipPercentage: NSNumber = Double(0) {
        didSet {
            self.updateBillAmount(nil, TipAmount: nil, TipPercentage: self.tipPercentage)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        //prepare the arrays
        for i in 0..<self.MAXBILLAMOUNT {
            self.billAmountsArray.append(NSNumber(double: Double(i+1)))
        }
        for i in 0..<self.MAXTIPAMOUNT {
            self.tipAmountsArray.append(NSNumber(double: Double(i+1)))
        }
        
        //prepare the tableviews
        self.billAmountTableView.delegate = self
        self.billAmountTableView.dataSource = self
        self.billAmountTableView.tag = BILLAMOUNTTAG
        self.billAmountTableView.estimatedRowHeight = 76.0
        self.billAmountTableView.separatorStyle = UITableViewCellSeparatorStyle.None
        let billTableViewCellString:String! = NSStringFromClass(BillTableViewCell).componentsSeparatedByString(".").last
        self.billAmountTableView.registerNib(UINib(nibName: billTableViewCellString, bundle: nil)!, forCellReuseIdentifier: billTableViewCellString)
        
        
        self.tipAmountTableView.delegate = self
        self.tipAmountTableView.dataSource = self
        self.tipAmountTableView.tag = TIPAMOUNTTAG
        self.tipAmountTableView.estimatedRowHeight = 76.0
        self.tipAmountTableView.separatorStyle = UITableViewCellSeparatorStyle.None
        let tipTableViewCellString:String! = NSStringFromClass(TipTableViewCell).componentsSeparatedByString(".").last
        self.tipAmountTableView.registerNib(UINib(nibName: tipTableViewCellString, bundle: nil)!, forCellReuseIdentifier: tipTableViewCellString)
        
        //configure color of view
        self.view.backgroundColor = GratuitousColorSelector.darkBackgroundColor()
        self.billAmountTableView.backgroundColor = GratuitousColorSelector.darkBackgroundColor()
        self.tipAmountTableView.backgroundColor = GratuitousColorSelector.darkBackgroundColor()
        self.tipPercentageTextLabel.textColor = GratuitousColorSelector.lightTextColor()
        self.totalAmountTextLabel.textColor = GratuitousColorSelector.lightTextColor()
        
        //check screensize and set text side adjustment
        self.textSizeAdjustment = self.checkScreenHeightForTextSizeAdjuster()
    }
    
    internal override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.prepareTotalAmountTextLabel()
        self.prepareTipPercentageTextLabel()
        self.gradientViewUpsideDown.isUpsideDown = true
    }
    
    internal override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        self.billAmount = Double(20.00)
    }
    
    internal func prepareTotalAmountTextLabel() {
        let font = self.totalAmountTextLabel.font.fontWithSize(self.totalAmountTextLabel.font.pointSize * CGFloat(self.textSizeAdjustment.floatValue))
        let textColor = self.totalAmountTextLabel.textColor
        let text = self.totalAmountTextLabel.text
        let shadow = NSShadow()
        shadow.shadowColor = GratuitousColorSelector.textShadowColor()
        shadow.shadowBlurRadius = 2.0
        shadow.shadowOffset = CGSizeMake(2.0, 2.0)
        let attributes = [
            NSForegroundColorAttributeName : textColor,
            NSFontAttributeName : font,
            //NSTextEffectAttributeName : NSTextEffectLetterpressStyle,
            NSShadowAttributeName : shadow
        ]
        self.totalAmountTextLabelAttributes = attributes
        let attributedString = NSAttributedString(string: text!, attributes: self.totalAmountTextLabelAttributes)
        self.totalAmountTextLabel.attributedText = attributedString
    }
    
    internal func prepareTipPercentageTextLabel() {
        let font = self.tipPercentageTextLabel.font.fontWithSize(self.tipPercentageTextLabel.font.pointSize * CGFloat(self.textSizeAdjustment.floatValue))
        let textColor = self.tipPercentageTextLabel.textColor
        let text = self.tipPercentageTextLabel.text
        let shadow = NSShadow()
        shadow.shadowColor = GratuitousColorSelector.textShadowColor()
        shadow.shadowBlurRadius = 2.0
        shadow.shadowOffset = CGSizeMake(2.0, 2.0)
        let attributes = [
            NSForegroundColorAttributeName : textColor,
            NSFontAttributeName : font,
            //NSTextEffectAttributeName : NSTextEffectLetterpressStyle,
            NSShadowAttributeName : shadow
        ]
        self.tipPercentageTextLabelAttributes = attributes
        let attributedString = NSAttributedString(string: text!, attributes: self.tipPercentageTextLabelAttributes)
        self.tipPercentageTextLabel.attributedText = attributedString
    }
    
    internal func checkScreenHeightForTextSizeAdjuster() -> Double {
        var textSizeAdjustment = 1.0
        if UIScreen.mainScreen().bounds.size.height > UIScreen.mainScreen().bounds.size.width {
            if UIScreen.mainScreen().bounds.size.height > 735 {
                textSizeAdjustment = Double(1.0)
            } else if UIScreen.mainScreen().bounds.size.height > 666 {
                textSizeAdjustment = Double(0.9)
            } else if UIScreen.mainScreen().bounds.size.height > 567 {
                textSizeAdjustment = Double(0.6)
            } else if UIScreen.mainScreen().bounds.size.height > 479 {
                textSizeAdjustment = Double(0.5)
            }
        } else {
            if UIScreen.mainScreen().bounds.size.width > 735 {
                textSizeAdjustment = Double(1.0)
            } else if UIScreen.mainScreen().bounds.size.width > 666 {
                textSizeAdjustment = Double(0.9)
            } else if UIScreen.mainScreen().bounds.size.width > 567 {
                textSizeAdjustment = Double(0.6)
            } else if UIScreen.mainScreen().bounds.size.width > 479 {
                textSizeAdjustment = Double(0.5)
            }
        }
        return textSizeAdjustment
    }
    
    internal func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch tableView.tag {
        case BILLAMOUNTTAG:
            return self.billAmountsArray.count
        default:
            return self.tipAmountsArray.count
        }
    }
    
    internal func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        switch tableView.tag {
        case BILLAMOUNTTAG:
            let billTableViewCellString:String = NSStringFromClass(BillTableViewCell).componentsSeparatedByString(".").last!
            let cell = tableView.dequeueReusableCellWithIdentifier(billTableViewCellString) as BillTableViewCell
            cell.billAmount = self.billAmountsArray[indexPath.row]
            return cell
        default:
            let tipTableViewCellString:String = NSStringFromClass(TipTableViewCell).componentsSeparatedByString(".").last!
            let cell = tableView.dequeueReusableCellWithIdentifier(tipTableViewCellString) as TipTableViewCell
            cell.tipAmount = self.tipAmountsArray[indexPath.row]
            return cell
        }
    }
    
    internal func updateBillAmount(billAmount:NSNumber?, TipAmount tipAmount:NSNumber?, TipPercentage tipPercentage:NSNumber?) {
        if let billAmount = billAmount {
            self.billAmountTableView.selectRowAtIndexPath(NSIndexPath(forRow: billAmount.integerValue - 1, inSection: 0), animated: true, scrollPosition: UITableViewScrollPosition.Middle)
            
            let tipAmount: NSNumber = billAmount.doubleValue * self.IDEALTIPPERCENTAGE
            let tipAmountRoundedString = NSString(format: "%.0f", tipAmount.doubleValue)
            let tipAmountRoundedNumber = NSNumber(double: tipAmountRoundedString.doubleValue)
            
            if tipAmountRoundedNumber.integerValue < 1 {
                self.tipAmount = Double(1.0)
            } else {
                self.tipAmount = tipAmountRoundedNumber
            }
        }
        if let tipAmount = tipAmount {
            self.tipAmountTableView.selectRowAtIndexPath(NSIndexPath(forRow: tipAmount.integerValue - 1, inSection: 0), animated: true, scrollPosition: UITableViewScrollPosition.Middle)
            
            self.tipPercentage = tipAmount.doubleValue/self.billAmount.doubleValue
        }
        if let tipPercentage = tipPercentage {
            self.tipPercentageTextLabel.attributedText = NSAttributedString(string: NSString(format: "%.0f%%", tipPercentage.doubleValue*100), attributes: self.tipPercentageTextLabelAttributes)
            self.totalAmountTextLabel.attributedText = NSAttributedString(string: NSString(format: "$%.0f", self.tipAmount.doubleValue+self.billAmount.doubleValue), attributes: self.totalAmountTextLabelAttributes)
        }
    }
    
    internal func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        switch tableView.tag {
        case BILLAMOUNTTAG:
            let billAmountSelected = self.billAmountsArray[indexPath.row]
            self.billAmount = self.billAmountsArray[indexPath.row]
        default:
            let tipAmountSelected = self.tipAmountsArray[indexPath.row]
            self.tipAmount = self.tipAmountsArray[indexPath.row]
        }
    }
    
    internal func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 76.0
    }
    
    override internal func preferredStatusBarStyle() -> UIStatusBarStyle {
        return UIStatusBarStyle.LightContent
    }
    
    override func supportedInterfaceOrientations() -> Int {
        return Int(UIInterfaceOrientationMask.All.rawValue)
    }
    
    internal override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}


        //initialize the window and the view controller
        let window = UIWindow(frame: UIScreen.mainScreen().bounds)
        let storyboard = UIStoryboard(name: "GratuitousSwift", bundle: nil)
        let tipViewController = storyboard.instantiateInitialViewController() as TipViewController
        
        //configure the window
        window.backgroundColor = UIColor.whiteColor();
        window.rootViewController = tipViewController
        window.makeKeyAndVisible()
        


