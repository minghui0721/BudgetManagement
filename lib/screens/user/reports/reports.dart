import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:wise/providers/TransactionsProvider.dart';
import 'package:wise/providers/userGlobalVariables.dart';
import 'package:wise/screens/user/profile/financialAdvice/goalsSetting.dart';

class ReportsPage extends StatefulWidget {
  const ReportsPage({Key? key}) : super(key: key);

  @override
  _ReportsPageState createState() => _ReportsPageState();
}

class _ReportsPageState extends State<ReportsPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _selectedChartIndex = 0;
  bool _isIncomeSelected = true;
  DateTimeRange? _selectedDateRange;
  int _touchedIndex = -1; // Track the touched section index
  String _selectedCategory = ""; // Track the selected category
  double _selectedAmount = 0.0; // Track the selected amount

  final List<DateTimeRange> _presetRanges = [
    DateTimeRange(
      start: DateTime.now().subtract(Duration(days: 7)),
      end: DateTime.now(),
    ),
    DateTimeRange(
      start: DateTime(DateTime.now().year, DateTime.now().month, 1),
      end: DateTime.now(),
    ),
    DateTimeRange(
      start: DateTime(DateTime.now().year, 1, 1),
      end: DateTime.now(),
    ),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _setDefaultDateRange();
    _fetchTransactionsForSelectedDateRange();

    // Add a listener to update the color on tab change
    _tabController.addListener(() {
      setState(() {}); // Trigger a rebuild whenever the tab changes
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _setDefaultDateRange() {
    _selectedDateRange = _presetRanges[0]; // Default to "Last 7 Days"
  }

  void _fetchTransactionsForSelectedDateRange() {
    if (_selectedDateRange != null) {
      Provider.of<TransactionProvider>(context, listen: false)
          .fetchTransactionsByUserIdAndDateRange(UserData().uid,
              _selectedDateRange!.start, _selectedDateRange!.end);
    }
  }

  Future<void> _selectCustomDateRange(BuildContext context) async {
    DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      initialDateRange: _selectedDateRange,
    );

    if (picked != null && picked != _selectedDateRange) {
      setState(() {
        _selectedDateRange = picked;
      });
      _fetchTransactionsForSelectedDateRange();
    }
  }

  void _onChartChange(int index) {
    setState(() {
      _selectedChartIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF1E1E1E),
      appBar: AppBar(
        backgroundColor: Color(0xFF1E1E1E),
        elevation: 0,
        title: Text(
          'Insight',
          style: TextStyle(
            color: Color(0xFFF8E4B2),
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Color(0xFFF8E4B2),
          tabs: [
            Tab(
              child: Text(
                'Statistics',
                style: TextStyle(
                  color: _tabController.index == 0
                      ? Color(0xFFF8E4B2)
                      : Colors.grey,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Tab(
              child: Text(
                'Savings Plan',
                style: TextStyle(
                  color: _tabController.index == 1
                      ? Color(0xFFF8E4B2)
                      : Colors.grey,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildStatisticsSection(context),
          GoalsSettingPage(
            userId: UserData().uid,
          ),
        ],
      ),
    );
  }

  Widget _buildStatisticsSection(BuildContext context) {
    return Consumer<TransactionProvider>(
      builder: (context, transactionProvider, child) {
        final categoryTotals =
            transactionProvider.getCategoryTotals(_isIncomeSelected);

        return Column(
          children: [
            SizedBox(height: 20.0),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: SingleChildScrollView(
                scrollDirection:
                    Axis.horizontal, // Enables horizontal scrolling
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    _buildPresetButton('Last 7 Days', 0),
                    SizedBox(width: 8.0),
                    _buildPresetButton('This Month', 1),
                    SizedBox(width: 8.0),
                    _buildPresetButton('This Year', 2),
                    SizedBox(width: 8.0),
                    _buildPresetButton('Custom', 0, isCustom: true),
                    SizedBox(width: 8.0),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 20.0),
              child: Text(
                _selectedDateRange == null
                    ? DateFormat('dd MMM yyyy').format(DateTime.now())
                    : '${DateFormat('dd MMM yyyy').format(_selectedDateRange!.start)} - ${DateFormat('dd MMM yyyy').format(_selectedDateRange!.end)}',
                style: TextStyle(color: Colors.white70),
              ),
            ),
            Expanded(child: _buildChartCard(categoryTotals)),
          ],
        );
      },
    );
  }

  Widget _buildPresetButton(String text, int index, {bool isCustom = false}) {
    bool isSelected;

    if (isCustom) {
      isSelected = _selectedDateRange != null &&
          !_presetRanges.contains(_selectedDateRange);
    } else {
      isSelected = _selectedDateRange == _presetRanges[index];
    }

    return GestureDetector(
      onTap: () {
        setState(() {
          if (isCustom) {
            _selectCustomDateRange(context);
          } else {
            _selectedDateRange = _presetRanges[index];
            _fetchTransactionsForSelectedDateRange();
          }
        });
      },
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 12.0),
        decoration: BoxDecoration(
          color: isSelected ? Color(0xFFF8E4B2) : Colors.transparent,
          borderRadius: BorderRadius.circular(8.0),
          border: Border.all(
            color: isSelected ? Color(0xFFF8E4B2) : Colors.grey,
          ),
        ),
        child: Text(
          text,
          style: TextStyle(
            color: isSelected ? Colors.black : Colors.grey,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildChartCard(Map<String, double> categoryTotals) {
    return Card(
      color: Color(0xFF5566CC),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.0),
      ),
      margin: EdgeInsets.symmetric(horizontal: 16.0, vertical: 25.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          // Wrap with SingleChildScrollView
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildChartButton('Bar Chart', 0),
                  SizedBox(width: 20.0),
                  VerticalDivider(
                    color: Colors.white70,
                    thickness: 1.0,
                    width: 50.0,
                  ),
                  _buildChartButton('Pie Chart', 1),
                ],
              ),
              SizedBox(height: 20.0),
              Text(
                _isIncomeSelected
                    ? 'Income Distribution'
                    : 'Expense Distribution',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 20.0),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Income',
                    style: TextStyle(
                      color:
                          _isIncomeSelected ? Color(0xFFE3B53C) : Colors.grey,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Switch(
                    value: _isIncomeSelected,
                    onChanged: (value) {
                      setState(() {
                        _isIncomeSelected = value;
                      });
                    },
                    activeColor: Color(0xFFF8E4B2),
                    inactiveThumbColor: Colors.grey,
                  ),
                  Text(
                    'Expense',
                    style: TextStyle(
                      color:
                          !_isIncomeSelected ? Color(0xFFE3B53C) : Colors.grey,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 10.0),
              Container(
                margin: EdgeInsets.only(top: 20.0),
                child: SizedBox(
                  height: _selectedChartIndex == 0
                      ? 300
                      : 250, // Height for bar and pie chart
                  child: _selectedChartIndex == 0
                      ? _buildBarChart(categoryTotals)
                      : _buildHalfPieChart(categoryTotals),
                ),
              ),
              if (_selectedChartIndex == 1) _buildLegend(categoryTotals),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBarChart(Map<String, double> categoryData) {
    if (categoryData.isEmpty) {
      return Center(
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 20.0, horizontal: 30.0),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.3),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.warning,
                color: Color(0xFFF8E4B2),
                size: 60.0,
              ),
              SizedBox(height: 12),
              Text(
                'No data available for the selected period',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 18.0,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 8),
              Text(
                'Please select a different date range or add new transactions.',
                style: TextStyle(
                  color: Colors.white54,
                  fontSize: 14.0,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    // Proceed with building the bar chart if there is data
    double maxY = categoryData.values.isNotEmpty
        ? categoryData.values.reduce((a, b) => a > b ? a : b) *
            1.5 // Increased for better visibility
        : 1;

    List<BarChartGroupData> barGroups = [];
    int index = 0;
    categoryData.forEach((category, amount) {
      barGroups.add(
        BarChartGroupData(
          x: index,
          barRods: [
            BarChartRodData(
              toY: amount,
              color: _getDynamicColor(index),
              width: 16, // Increased width for better visibility
              borderRadius: BorderRadius.circular(4),
            ),
          ],
        ),
      );
      index++;
    });

    return BarChart(
      BarChartData(
        maxY: maxY,
        barGroups: barGroups,
        titlesData: FlTitlesData(
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 50,
              getTitlesWidget: (double value, TitleMeta meta) {
                String category = categoryData.keys.elementAt(value.toInt());
                return Padding(
                  padding: const EdgeInsets.only(top: 5.0), // Reduced padding
                  child: Transform.rotate(
                    angle: 0 * 3.1415927 / 180,
                    child: Text(
                      category,
                      style: TextStyle(color: Colors.white, fontSize: 12),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                );
              },
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              interval: maxY / 4, // Adjusted interval
              getTitlesWidget: (double value, TitleMeta meta) {
                return Text(
                  value.toInt().toString(),
                  style: TextStyle(color: Colors.white70, fontSize: 10),
                );
              },
            ),
          ),
          rightTitles: AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
        ),
        gridData: FlGridData(show: true),
        borderData: FlBorderData(show: false),
      ),
    );
  }

  Widget _buildHalfPieChart(Map<String, double> categoryTotals) {
    if (categoryTotals.isEmpty) {
      return Center(
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 20.0, horizontal: 30.0),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.3),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.warning,
                color: Color(0xFFF8E4B2),
                size: 60.0,
              ),
              SizedBox(height: 12),
              Text(
                'No data available for the selected period',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 18.0,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 8),
              Text(
                'Please select a different date range or add new transactions.',
                style: TextStyle(
                  color: Colors.white54,
                  fontSize: 14.0,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    double totalAmount =
        categoryTotals.values.fold(0, (sum, amount) => sum + amount);
    List<PieChartSectionData> sections = categoryTotals.entries.map((entry) {
      int index = categoryTotals.keys.toList().indexOf(entry.key);
      double percentage = (entry.value / totalAmount) * 100;
      return PieChartSectionData(
        color: _getDynamicColor(index), // Assign dynamic color
        value: entry.value,
        title: '${percentage.toStringAsFixed(1)}%',
        radius: 50,
        titleStyle: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
        borderSide: BorderSide(color: Colors.black.withOpacity(0.1), width: 2),
      );
    }).toList();

    return Stack(
      children: [
        Container(
          width: double.infinity,
          height: 220,
          child: PieChart(
            PieChartData(
              startDegreeOffset: 180,
              sectionsSpace: 5,
              centerSpaceRadius: 60,
              sections: sections,
              pieTouchData: PieTouchData(
                touchCallback:
                    (FlTouchEvent event, PieTouchResponse? pieTouchResponse) {
                  if (!event.isInterestedForInteractions ||
                      pieTouchResponse == null) return;

                  final touchedIndex =
                      pieTouchResponse.touchedSection?.touchedSectionIndex ??
                          -1;

                  setState(() {
                    if (touchedIndex >= 0) {
                      _selectedCategory =
                          categoryTotals.keys.toList()[touchedIndex];
                      _selectedAmount = categoryTotals[_selectedCategory]!;
                      _touchedIndex = touchedIndex;
                    } else {
                      _selectedCategory = "";
                      _selectedAmount = 0.0;
                      _touchedIndex = -1;
                    }
                  });
                },
              ),
            ),
          ),
        ),
        _buildSelectedInfoInsideChart(), // Display selected data in the center
      ],
    );
  }

  Widget _buildSelectedInfo() {
    if (_selectedCategory.isNotEmpty) {
      return Padding(
        padding: const EdgeInsets.all(8.0),
        child: Text(
          'Selected: $_selectedCategory - \$${_selectedAmount.toStringAsFixed(2)}',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      );
    } else {
      return SizedBox.shrink(); // or show a default message
    }
  }

  Widget _buildSelectedInfoInsideChart() {
    return Align(
      alignment: Alignment.center,
      child: Center(
        child: _selectedCategory.isNotEmpty
            ? Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment:
                    MainAxisAlignment.center, // Center vertically
                children: [
                  Text(
                    _selectedCategory,
                    style: TextStyle(
                      color: _getDynamicColor(
                          _touchedIndex), // Match color with the selected section
                      fontSize: 16.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    '\$${_selectedAmount.toStringAsFixed(2)}',
                    style: TextStyle(
                      color: _getDynamicColor(
                          _touchedIndex), // Match color with the selected section
                      fontSize: 14.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              )
            : Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment:
                    MainAxisAlignment.center, // Center vertically
                children: [
                  Text(
                    'Tap on a section',
                    style: TextStyle(
                      color: Colors.white54,
                      fontSize: 16.0,
                    ),
                  ),
                  SizedBox(
                      height: 10.0), // Space below the "Tap on a section" text
                ],
              ),
      ),
    );
  }

  Color _getCategoryColor(String category, Map<String, double> categoryTotals) {
    // Get the index of the category in the map to assign a color from the palette
    int index = categoryTotals.keys.toList().indexOf(category);
    return _getDynamicColor(index);
  }

  // Define a list of colors for the dynamic color palette
  final List<Color> _colorPalette = [
    Colors.blue.shade400,
    Colors.green.shade400,
    Colors.red.shade400,
    Colors.orange.shade400,
    Colors.purple.shade400,
    Colors.cyan.shade400,
    Colors.pink.shade400,
    Colors.indigo.shade400,
    Colors.teal.shade400,
    Colors.amber.shade400,
  ];

  Color _getDynamicColor(int index) {
    // Use modulo to cycle through colors if there are more categories than colors
    return _colorPalette[index % _colorPalette.length];
  }

  Widget _buildChartButton(String text, int index) {
    return GestureDetector(
      onTap: () => _onChartChange(index),
      child: Column(
        children: [
          Text(
            text,
            style: TextStyle(
              color: _selectedChartIndex == index
                  ? Color(0xFFF8E4B2)
                  : Colors.white,
              fontSize: 18.0, // Slightly larger font size
              fontWeight: FontWeight.bold,
            ),
          ),
          AnimatedContainer(
            duration: Duration(milliseconds: 200),
            curve: Curves.easeInOut,
            width: _selectedChartIndex == index ? 80 : 0, // Expanding effect
            height: 4, // Increase thickness of the indicator line
            decoration: BoxDecoration(
              color: Color(0xFFF8E4B2),
              borderRadius: BorderRadius.circular(2), // Rounded corners
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLegend(Map<String, double> categoryTotals) {
    return Wrap(
      spacing: 20.0,
      alignment: WrapAlignment.center,
      children: categoryTotals.keys.map((category) {
        int index = categoryTotals.keys.toList().indexOf(category);
        return _legendItem(
          color: _getDynamicColor(index),
          text: category,
        );
      }).toList(),
    );
  }

  Widget _legendItem({required Color color, required String text}) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        CircleAvatar(radius: 5, backgroundColor: color),
        SizedBox(width: 8),
        Text(text, style: TextStyle(color: Colors.white)),
      ],
    );
  }
}
