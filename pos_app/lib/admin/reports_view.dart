import 'dart:async';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'dart:convert';
import '../main.dart';
import '../shared/responsive_layout.dart';

class ReportsView extends StatefulWidget {
  const ReportsView({super.key});

  @override
  State<ReportsView> createState() => _ReportsViewState();
}

class _ReportsViewState extends State<ReportsView> {
  String selectedTimeRange = 'This Week';
  DateTime? startDate;
  DateTime? endDate;
  Map<String, dynamic>? reportData;
  bool isLoading = true;
  String? errorMessage;
  StreamSubscription? _eventSubscription;

  @override
  void initState() {
    super.initState();
    _updateDatesFromTimeRange();
    _fetchReportData();
    _subscribeToEvents();
  }

  @override
  void dispose() {
    _eventSubscription?.cancel();
    super.dispose();
  }

  void _updateDatesFromTimeRange() {
    final now = DateTime.now();
    switch (selectedTimeRange) {
      case 'Today':
        startDate = DateTime(now.year, now.month, now.day);
        endDate = DateTime(now.year, now.month, now.day, 23, 59, 59);
        break;
      case 'This Week':
        final monday = now.subtract(Duration(days: now.weekday - 1));
        startDate = DateTime(monday.year, monday.month, monday.day);
        endDate = DateTime(now.year, now.month, now.day, 23, 59, 59);
        break;
      case 'This Month':
        startDate = DateTime(now.year, now.month, 1);
        endDate = DateTime(now.year, now.month, now.day, 23, 59, 59);
        break;
      case 'Custom':
        // Don't auto-update dates for Custom
        break;
    }
  }

  void _subscribeToEvents() {
    _eventSubscription = posEventStreamController.stream.listen((event) {
      if (event.eventType == 'checkout_completed') {
        _fetchReportDataQuietly();
      }
    });
  }

  Future<void> _fetchReportDataQuietly() async {
    try {
      final jsonString = await client.reports.getSummaryJson(
        startDate: startDate,
        endDate: endDate,
      );
      if (mounted) {
        setState(() {
          reportData = json.decode(jsonString);
        });
      }
    } catch (e) {
      // Silent fail
    }
  }

  Future<void> _fetchReportData() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final jsonString = await client.reports.getSummaryJson(
        startDate: startDate,
        endDate: endDate,
      );
      if (mounted) {
        setState(() {
          reportData = json.decode(jsonString);
          isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          errorMessage = 'Failed to load report data: $e';
          isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(errorMessage!, style: const TextStyle(color: Colors.red)),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _fetchReportData,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          const SizedBox(height: 32),
          _buildFilters(),
          const SizedBox(height: 32),
          _buildSummaryCards(),
          const SizedBox(height: 32),
          if (ResponsiveLayout.isMobile(context))
            Column(
              children: [
                _buildSalesByDayChart(),
                const SizedBox(height: 32),
                _buildSalesByCategoryChart(),
              ],
            )
          else
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(flex: 2, child: _buildSalesByDayChart()),
                const SizedBox(width: 32),
                Expanded(flex: 1, child: _buildSalesByCategoryChart()),
              ],
            ),
          const SizedBox(height: 32),
          _buildTopSellingItems(),
          const SizedBox(height: 32),
          _buildBusiestHoursChart(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Wrap(
      alignment: WrapAlignment.spaceBetween,
      crossAxisAlignment: WrapCrossAlignment.center,
      spacing: 16,
      runSpacing: 16,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Reports Dashboard',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Color(0xFF0F172A),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Sales analytics and insights',
              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
            ),
          ],
        ),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            _buildExportButton('CSV', Icons.download_outlined),
            _buildExportButton('PDF', Icons.picture_as_pdf_outlined),
          ],
        ),
      ],
    );
  }

  Widget _buildExportButton(String label, IconData icon) {
    return OutlinedButton.icon(
      onPressed: () {},
      icon: Icon(icon, size: 20),
      label: Text(label),
      style: OutlinedButton.styleFrom(
        foregroundColor: const Color(0xFF0F172A),
        side: BorderSide(color: Colors.grey[300]!),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  Widget _buildFilters() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.grey[100]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Filters',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 16,
            runSpacing: 16,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: selectedTimeRange,
                    items: ['Today', 'This Week', 'This Month', 'Custom']
                        .map(
                          (e) => DropdownMenuItem(value: e, child: Text(e)),
                        )
                        .toList(),
                    onChanged: (v) {
                      setState(() {
                        selectedTimeRange = v!;
                        _updateDatesFromTimeRange();
                      });
                      _fetchReportData();
                    },
                  ),
                ),
              ),
              _buildDateButton(
                'Start Date',
                Icons.calendar_today_outlined,
                startDate,
                () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: startDate ?? DateTime.now(),
                    firstDate: DateTime(2020),
                    lastDate: DateTime.now(),
                  );
                  if (picked != null) {
                    setState(() {
                      startDate = DateTime(picked.year, picked.month, picked.day);
                      selectedTimeRange = 'Custom';
                    });
                    _fetchReportData();
                  }
                },
              ),
              _buildDateButton(
                'End Date',
                Icons.calendar_today_outlined,
                endDate,
                () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: endDate ?? startDate ?? DateTime.now(),
                    firstDate: DateTime(2020),
                    lastDate: DateTime.now(),
                  );
                  if (picked != null) {
                    setState(() {
                      endDate = DateTime(picked.year, picked.month, picked.day, 23, 59, 59);
                      selectedTimeRange = 'Custom';
                    });
                    _fetchReportData();
                  }
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDateButton(String label, IconData icon, DateTime? selectedDate, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey[200]!),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 18, color: Colors.grey[600]),
            const SizedBox(width: 12),
            Text(
              selectedDate != null ? DateFormat('MMM d, yyyy').format(selectedDate) : label,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryCards() {
    final currencyFormat = NumberFormat.simpleCurrency(name: 'EUR');
    final totalRevenue = reportData?['total_revenue'] ?? 0.0;
    final totalOrders = reportData?['total_orders'] ?? 0;
    final avgOrderValue = reportData?['avg_order_value'] ?? 0.0;

    final cards = [
      _buildSummaryCardInner(
        'Total Sales',
        currencyFormat.format(totalRevenue),
        '',
        Icons.attach_money,
      ),
      _buildSummaryCardInner(
        'Orders',
        totalOrders.toString(),
        '',
        Icons.shopping_cart_outlined,
      ),
      _buildSummaryCardInner(
        'Avg Order Value',
        currencyFormat.format(avgOrderValue),
        '',
        Icons.trending_up,
      ),
      _buildSummaryCardInner('Avg Wait Time', '0 min', '', Icons.access_time),
    ];

    if (ResponsiveLayout.isMobile(context)) {
      return Column(
        children: cards
            .map((c) => Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: SizedBox(width: double.infinity, child: c),
                ))
            .toList(),
      );
    }

    return Row(
      children: cards
          .map((c) => Expanded(
                child: Padding(
                  padding: EdgeInsets.only(
                      right: c == cards.last ? 0 : 24.0),
                  child: c,
                ),
              ))
          .toList(),
    );
  }

  Widget _buildSummaryCardInner(
    String title,
    String value,
    String trend,
    IconData icon,
  ) {
    final bool hasTrend = trend.isNotEmpty;
    final bool isPositive = trend.contains('+');
    return Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: Colors.grey[100]!),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Icon(icon, color: Colors.grey[400], size: 20),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              value,
              style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ),
            if (hasTrend) ...[
              const SizedBox(height: 8),
              Text(
                trend,
                style: TextStyle(
                  color: isPositive ? Colors.green : Colors.red,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ],
        ),
      );
  }

  Widget _buildSalesByDayChart() {
    final List<dynamic> salesByDay = reportData?['sales_by_day'] ?? [];

    // Fallback data if no sales
    final List<BarChartGroupData> barGroups = salesByDay.isEmpty
        ? List.generate(7, (i) => _makeGroupData(i, 0))
        : salesByDay.asMap().entries.map((e) {
            return _makeGroupData(
              e.key,
              (e.value['revenue'] as num).toDouble(),
            );
          }).toList();

    double maxY = 0;
    for (var item in salesByDay) {
      if ((item['revenue'] as num).toDouble() > maxY) {
        maxY = (item['revenue'] as num).toDouble();
      }
    }
    maxY = maxY == 0 ? 1000 : maxY * 1.2;

    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.grey[100]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Sales by Day',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const Text(
            'Daily sales and order count',
            style: TextStyle(color: Colors.grey, fontSize: 14),
          ),
          const SizedBox(height: 32),
          AspectRatio(
            aspectRatio: ResponsiveLayout.isMobile(context) ? 1.2 : 1.7,
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: maxY,
                barTouchData: BarTouchData(enabled: false),
                titlesData: FlTitlesData(
                  show: true,
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        if (salesByDay.isEmpty) return const SizedBox();
                        final int idx = value.toInt();
                        if (idx < 0 || idx >= salesByDay.length) {
                          return const SizedBox();
                        }

                        final dateStr = salesByDay[idx]['day'] as String;
                        final date = DateTime.parse(dateStr);
                        final dayName = DateFormat('E').format(date);

                        return Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Text(
                            dayName,
                            style: const TextStyle(
                              color: Colors.grey,
                              fontSize: 12,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 40,
                      getTitlesWidget: (value, meta) {
                        if (value % (maxY / 4).round() == 0) {
                          return Text(
                            value.toInt().toString(),
                            style: const TextStyle(
                              color: Colors.grey,
                              fontSize: 12,
                            ),
                          );
                        }
                        return const SizedBox();
                      },
                    ),
                  ),
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                ),
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  getDrawingHorizontalLine: (value) => FlLine(
                    color: Colors.grey[200]!,
                    strokeWidth: 1,
                    dashArray: [5, 5],
                  ),
                ),
                borderData: FlBorderData(show: false),
                barGroups: barGroups,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildLegendItem('Sales (€)', Colors.blue),
              const SizedBox(width: 24),
              _buildLegendItem('Orders', const Color(0xFF10B981)),
            ],
          ),
        ],
      ),
    );
  }

  BarChartGroupData _makeGroupData(int x, double y) {
    return BarChartGroupData(
      x: x,
      barRods: [
        BarChartRodData(
          toY: y,
          color: const Color(0xFF10B981),
          width: 20,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
        ),
      ],
    );
  }

  Widget _buildLegendItem(String label, Color color) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 8),
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 14)),
      ],
    );
  }

  Widget _buildSalesByCategoryChart() {
    final List<dynamic> salesByCategory =
        reportData?['sales_by_category'] ?? [];

    final List<PieChartSectionData> sections = salesByCategory.isEmpty
        ? [
            PieChartSectionData(
              value: 1,
              title: 'No Data',
              color: Colors.grey,
              radius: 80,
            ),
          ]
        : salesByCategory.asMap().entries.map((e) {
            final colors = [
              Colors.blue,
              const Color(0xFF10B981),
              Colors.orange,
              Colors.pink,
              Colors.purple,
            ];
            final color = colors[e.key % colors.length];
            final double revenue = (e.value['revenue'] as num).toDouble();
            final String category = e.value['category'] as String;

            return PieChartSectionData(
              value: revenue,
              title: category,
              color: color,
              radius: 80,
              titleStyle: TextStyle(
                fontSize: 12,
                color: color,
                fontWeight: FontWeight.bold,
              ),
            );
          }).toList();

    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.grey[100]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Sales by Category',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const Text(
            'Revenue distribution',
            style: TextStyle(color: Colors.grey, fontSize: 14),
          ),
          const SizedBox(height: 32),
          AspectRatio(
            aspectRatio: 1,
            child: PieChart(
              PieChartData(
                sectionsSpace: 2,
                centerSpaceRadius: 40,
                sections: sections,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopSellingItems() {
    final List<dynamic> items = reportData?['top_items'] ?? [];
    final currencyFormat = NumberFormat.simpleCurrency(name: 'EUR');

    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.grey[100]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Top Selling Items',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const Text(
            'Best performers this period',
            style: TextStyle(color: Colors.grey, fontSize: 14),
          ),
          const SizedBox(height: 24),
          if (items.isEmpty)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(20),
                child: Text('No sales data available'),
              ),
            ),
          ...items.asMap().entries.map((e) {
            final double revenue = (e.value['total_revenue'] as num).toDouble();
            final int qty = (e.value['total_qty'] as num).toInt();

            return Padding(
              padding: const EdgeInsets.only(bottom: 16.0),
              child: Row(
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      '${e.key + 1}',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          e.value['name'] as String,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Text(
                          '$qty sold',
                          style: TextStyle(
                            color: Colors.grey[500],
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    currencyFormat.format(revenue),
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildBusiestHoursChart() {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.grey[100]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Busiest Hours',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const Text(
            'Orders heatmap by day and time',
            style: TextStyle(color: Colors.grey, fontSize: 14),
          ),
          const SizedBox(height: 32),
          AspectRatio(
            aspectRatio: ResponsiveLayout.isMobile(context) ? 1.2 : 2.0,
            child: LineChart(
              LineChartData(
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  getDrawingHorizontalLine: (v) => FlLine(
                    color: Colors.grey[200]!,
                    strokeWidth: 1,
                    dashArray: [5, 5],
                  ),
                ),
                titlesData: FlTitlesData(
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      interval: 3,
                      getTitlesWidget: (v, m) {
                        final hours = ['9am', '12pm', '3pm', '6pm', '9pm'];
                        int idx = (v.toInt() - 9) ~/ 3;
                        if (idx >= 0 &&
                            idx < hours.length &&
                            (v.toInt() - 9) % 3 == 0) {
                          return Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Text(
                              hours[idx],
                              style: const TextStyle(
                                color: Colors.grey,
                                fontSize: 12,
                              ),
                            ),
                          );
                        }
                        return const SizedBox();
                      },
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 30,
                      interval: 15,
                      getTitlesWidget: (v, m) => Text(
                        v.toInt().toString(),
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ),
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                ),
                borderData: FlBorderData(show: false),
                minX: 9,
                maxX: 21,
                minY: 0,
                maxY: 60,
                lineBarsData: [
                  LineChartBarData(
                    spots: [],
                    isCurved: true,
                    color: Colors.orange,
                    barWidth: 2,
                    isStrokeCapRound: true,
                    dotData: const FlDotData(show: true),
                    belowBarData: BarAreaData(show: false),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          const Center(
            child: Text(
              'No heatmap data available',
              style: TextStyle(color: Colors.grey, fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }
}
