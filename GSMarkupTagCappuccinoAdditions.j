@import "GSMarkupTagView.j"

@implementation GSMarkupTagFlashView : GSMarkupTagView
+ (CPString) tagName
{
  return @"flashView";
}

+ (Class) platformObjectClass
{
  return [CPFlashView class];
}

- (id) initPlatformObject: (id)platformObject
{	platformObject = [super initPlatformObject: platformObject];

    var name = [_attributes objectForKey: @"ressource"];

    if (name != nil)
	{	[platformObject setFlashMovie: [CPFlashMovie flashMovieWithFile: [CPString stringWithFormat:@"%@/%@", [[CPBundle mainBundle] resourcePath], name ]] ];
	}

	return platformObject;
}
@end


@implementation GSMarkupTagLevelIndicator : GSMarkupTagControl
+ (CPString) tagName
{
  return @"levelIndicator";
}

+ (Class) platformObjectClass
{
  return [CPLevelIndicator class];
}

- (id) initPlatformObject: (id)platformObject
{	platformObject = [super initPlatformObject: platformObject];

	var min;
	var max;
	var warning;
	var critical;
	var current;

	min = [_attributes objectForKey: @"min"];
	if (min != nil)
    {	[platformObject setMinValue: [min doubleValue]];
    }

	max = [_attributes objectForKey: @"max"];
	if (max != nil)
    {	[platformObject setMaxValue: [max doubleValue]];
    }
	warning = [_attributes objectForKey: @"warning"];
	if (warning != nil)
    {	[platformObject setWarningValue: [warning doubleValue]];
    }
	critical = [_attributes objectForKey: @"critical"];
	if (critical != nil)
    {	[platformObject setCriticalValue: [critical doubleValue]];
    }

  /* minimum size is 83x17*/
	var height;
	height = [_attributes objectForKey: @"height"];
	if (height == nil)
	{
		[_attributes setObject: @"25" forKey: @"height"];
	}
	var width;
	width = [_attributes objectForKey: @"width"];
	if (width == nil)
    {	[_attributes setObject: @"250" forKey: @"width"];
    }

	return platformObject;
}
@end

@implementation GSMarkupOperator: GSMarkupTagObject

+ (CPString) tagName
{
  return @"operator";
}
-(CPArray) content
{	return _content;
}
/* Will never be called.  */
- (id) allocPlatformObject
{	return nil;
}
-(CPNumber) operator
{	var type= [_attributes objectForKey:"type"];
	if( type == "equal") return [CPNumber numberWithInt: CPEqualToPredicateOperatorType];
	else if( type == "begins") return [CPNumber numberWithInt: CPBeginsWithPredicateOperatorType];
	else if( type == "ends") return [CPNumber numberWithInt: CPEndsWithPredicateOperatorType];
	return nil
}
@end


@implementation GSMarkupLexpression: GSMarkupTagObject

+ (CPString) tagName
{
  return @"lexpression";
}
-(CPArray) content
{	return _content;
}
/* Will never be called.  */
- (id) allocPlatformObject
{	return nil;
}
-(CPString) keyPath
{	return [_attributes objectForKey:"keyPath"];
}
@end

@implementation GSMarkupRexpression: GSMarkupTagObject

+ (CPString) tagName
{
  return @"rexpression";
}
-(CPArray) content
{	return _content;
}
/* Will never be called.  */
- (id) allocPlatformObject
{	return nil;
}
-(CPString) keyPath
{	return [_attributes objectForKey:"keyPath"];
}
@end


@implementation GSMarkupRowTemplate: GSMarkupTagObject

+ (CPString) tagName
{
  return @"rowTemplate";
}
/* Will never be called.  */
- (id) allocPlatformObject
{	return nil;
}
@end

@implementation CPPredicateEditor(SizeToFitFix)
-(void) sizeToFit
{
}
@end

@implementation GSMarkupTagPredicateEditor : GSMarkupTagView
+ (CPString) tagName
{	return @"predicateEditor";
}

+ (Class) platformObjectClass
{	return [CPPredicateEditor class];
}

- (id) initPlatformObject: (id)platformObject
{	platformObject = [super initPlatformObject: platformObject];

// now extract columns and PK...
	var rowTemplates=[CPMutableArray new];
    var i, count = _content.length;
	for (i = 0 ; i < count; i++)
	{	var v = _content[i];
		if([v isKindOfClass: [GSMarkupRowTemplate class] ])
		{	var expressions=[v content];
			var j,l1=expressions.length;
			var lexpressions=[CPMutableArray new];
			var ops=[CPMutableArray new];
			for(j=0;j<l1;j++)
			{	var expr=expressions[j];
				if([expr isKindOfClass: [GSMarkupLexpression class] ])
					[lexpressions addObject: [CPExpression expressionForKeyPath: [expr keyPath] ]];
				else if([expr isKindOfClass: [GSMarkupOperator class] ])
					 if([expr operator]) [ops addObject: [expr operator]];
			}
			var rowTemplate=[[CPPredicateEditorRowTemplate alloc]
				 initWithLeftExpressions: lexpressions
			rightExpressionAttributeType: CPStringAttributeType		//<!> fixme
								modifier: 0	//<!> fixme
							   operators: ops
								 options: 0];	//<!> fixme
			[rowTemplates addObject: rowTemplate];
		}
	}

	[platformObject setNestingMode: CPRuleEditorNestingModeCompound];
	[rowTemplates addObject: [ [CPPredicateEditorRowTemplate alloc] initWithCompoundTypes:
			[CPArray arrayWithObjects: [CPNumber numberWithInt: CPAndPredicateType], [CPNumber numberWithInt: CPOrPredicateType], [CPNumber numberWithInt: CPNotPredicateType]  ] ] ];
	[platformObject setRowTemplates: rowTemplates];
	[platformObject setFormattingStringsFilename: nil];	// fixes capp issue
	return platformObject;
}
@end

@implementation GSMarkupTagPredicate : GSMarkupTagObject
+ (CPString) tagName
{	return @"predicate";
}

+ (Class) platformObjectClass
{	return nil;
}

- (id) initPlatformObject: (id)platformObject
{	platformObject=[CPPredicate predicateWithFormat: [_attributes objectForKey:"format"] argumentArray: nil ];
	return platformObject;
}
@end

@implementation GSMarkupTagTabViewItem : GSMarkupTagObject
+ (CPString) tagName
{
  return @"tabViewItem";
}

+ (Class) platformObjectClass
{
  return nil;
}

-(CPString) title
{	return [_attributes objectForKey:"title"];
}
- (id) initPlatformObject: (id)platformObject
{	platformObject=[[CPTabViewItem alloc] initWithIdentifier: [self title] ];
	return platformObject;
}
@end

@implementation GSMarkupTagTabView : GSMarkupTagView
+ (CPString) tagName
{
  return @"tabView";
}

+ (Class) platformObjectClass
{
  return [CPTabView class];
}

-(int) type
{	if([_attributes objectForKey: "type"]=="topBezel") return CPTopTabsBezelBorder;
	return CPNoTabsBezelBorder;
}
- (id) initPlatformObject: (id)platformObject
{	platformObject = [super initPlatformObject: platformObject];
	[platformObject setTabViewType: [self type]];

    var  i, count = _content.length;
	for (i = 0 ; i < count; i++)
	{	var item = [_content[i] platformObject];
        [item setView: [[_content[i] content][0] platformObject] ];
        [item setLabel: [_content[i] title] ];
		[platformObject addTabViewItem: item];
	}
	return platformObject;
}
@end

@implementation  CPTabView(AutoLayoutDefaults)
- (GSAutoLayoutAlignment) autolayoutDefaultVerticalAlignment
{	return GSAutoLayoutExpand;
}
- (GSAutoLayoutAlignment) autolayoutDefaultHorizontalAlignment
{	return GSAutoLayoutExpand;
}

@end


@implementation GSMarkupTagCheckBox : GSMarkupTagControl
+ (CPString) tagName
{
  return @"checkBox";
}

+ (Class) platformObjectClass
{
  return [CPCheckBox class];
}

- (id) initPlatformObject: (id)platformObject
{	platformObject = [super initPlatformObject: platformObject];
	[platformObject setTitle: [_attributes objectForKey:"title"] ];
	return platformObject;
}
@end

@implementation SimleImageViewCollectionViewItem: CPCollectionViewItem
{ CPImage _img;
  CPImageView _imgv;
}
- (void)imageDidLoad:(CPImage)image
{	var mySize=[image size];
	[_imgv setBounds: CPMakeRect(0, 0, mySize.width, mySize.height)];
}
-(CPView) loadView
{	_img=[_representedObject provideCollectionViewImage];
	_imgv=[CPImageView new];
	[_imgv setImage: _img];
	var size=[_img size];
	if(size) [_imgv setBounds: CPMakeRect(0,0, size.width, size.height)];
	else [_imgv setDelegate: self];
	var myview=[CPBox new];
    [myview setBorderType:CPBezelBorder];
	[myview setContentView: _imgv];
	[self setView: myview];
	return myview;
}
@end

@implementation CPCollectionView(KVB)
-(void) setObjectValue: someArray
{	[self setContent: someArray];
}
-(CPArray) value
{	return [self content];
}
-(void) setValue:(CPArray) someArray
{	return [self setObjectValue: someArray];
}
- (GSAutoLayoutAlignment) autolayoutDefaultVerticalAlignment
{	return GSAutoLayoutExpand;
}
- (GSAutoLayoutAlignment) autolayoutDefaultHorizontalAlignment
{	return GSAutoLayoutExpand;
}
@end

@implementation GSMarkupTagCollectionView : GSMarkupTagView
+ (CPString) tagName
{
  return @"collectionView";
}

+ (Class) platformObjectClass
{
  return [CPCollectionView class];
}

- (id) initPlatformObject: (id)platformObject
{	platformObject = [super initPlatformObject: platformObject];
	[platformObject setSelectable: [self boolValueForAttribute:"selectable"]==1 ];
	[platformObject setAllowsEmptySelection: [self boolValueForAttribute:"emptySelectionAllowed"]==1 ];
	[platformObject setAllowsMultipleSelection: [self boolValueForAttribute:"multipleSelectionAllowed"]==1 ];
	[platformObject setMaxNumberOfRows: [self intValueForAttribute:"maxRows"] ];
	[platformObject setMaxNumberOfColumns: [self intValueForAttribute:"maxColumns"] ];
	var width=[self intValueForAttribute:"itemWidth"];
	var height=[self intValueForAttribute:"itemHeight"];
	if(width && height)
	{	var mysize=CPMakeSize(width,height);
		[platformObject setMinItemSize: mysize ];
		[platformObject setMaxItemSize: mysize ];
	}
	var width=[self intValueForAttribute:"minItemWidth"];
	var height=[self intValueForAttribute:"minItemHeight"];
	if(width && height)
	{	[platformObject setMinItemSize: CPMakeSize(width,height) ];
	}
	var width=[self intValueForAttribute:"maxItemWidth"];
	var height=[self intValueForAttribute:"maxItemHeight"];
	if(width && height)
	{	[platformObject setMaxItemSize: CPMakeSize(width,height) ];
	}
	var proto=[SimleImageViewCollectionViewItem new];
	[platformObject setItemPrototype: proto];
	return platformObject;
}

- (id) postInitPlatformObject: (id)platformObject
{	platformObject=[super postInitPlatformObject: platformObject];
	[platformObject tile];
	return platformObject;
}
@end

@implementation GSMarkupTagButtonBar : GSMarkupTagView
+ (CPString) tagName
{
  return @"ButtonBar";
}

+ (Class) platformObjectClass
{
  return [CPButtonBar class];
}

- (id) initPlatformObject: (id)platformObject
{	[_attributes setObject: @"25" forKey: @"height"];
	platformObject = [super initPlatformObject: platformObject];
	[platformObject setHasResizeControl: [self boolValueForAttribute:"resizable"]==1 ];
	var buttons=[];

	var peek;
	if(peek=[self stringValueForAttribute:"plusButtonAction"] )
	{	var button=[CPButtonBar plusButton];
		[button setAction: CPSelectorFromString (peek)];
		[buttons addObject: button];
	}
	if(peek=[self stringValueForAttribute:"minusButtonAction"] )
	{	var button=[CPButtonBar minusButton];
		[button setAction: CPSelectorFromString (peek)];
		[buttons addObject: button];
	}
	if([self boolValueForAttribute:"actionsButton"]==1) [buttons addObject:[CPButtonBar actionPopupButton] ];

	[platformObject setButtons: buttons ];
	return platformObject;
}

@end

@implementation CPButtonBar(RennaissanceAdditions)
-(void) setTarget: someTarget
{	[[self buttons] makeObjectsPerformSelector:@selector(setTarget:) withObject: someTarget];
}
- (GSAutoLayoutAlignment) autolayoutDefaultHorizontalAlignment
{	return GSAutoLayoutExpand;
}
@end