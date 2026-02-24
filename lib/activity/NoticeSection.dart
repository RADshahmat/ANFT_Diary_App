import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // For formatting date and time
import 'config.dart';

class NoticeDetailsPage extends StatelessWidget {
  final String noticeTitle;
  final String noticeDetails;

  NoticeDetailsPage({
    required this.noticeTitle,
    required this.noticeDetails,
  });

  @override
  Widget build(BuildContext context) {
    // Extract date and time from the noticeDetails string
    final detailsParts = noticeDetails.split('\n');
    final dateTime = detailsParts[0].replaceAll('Date: ', '').trim();
    final formattedDate = DateFormat('EEEE, MMM d, yyyy').format(DateTime.parse(dateTime)); // Format date
    final formattedTime = DateFormat('hh:mm a').format(DateTime.parse(dateTime)); // Format time

    // Extract details and attachment
    final detailsText = detailsParts
        .sublist(1, detailsParts.length - 1)
        .join('\n')
        .replaceAll('Attachment: ', '') // Remove the "Attachment:" label from any lingering text
        .trim();
    final attachment = detailsParts.last.replaceAll('Attachment: ', '').trim();

    return Scaffold(
      appBar: AppBar(
        title: Text('Notice Details'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title
              Text(
                noticeTitle,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              SizedBox(height: 8),
              // Formatted Date and Time
              Text(
                '$formattedDate at $formattedTime',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  color: Colors.grey[600],
                ),
              ),
              SizedBox(height: 20),
              // Details Section
              Text(
                detailsText,
                style: TextStyle(
                  fontSize: 18,
                  height: 1.5,
                  color: Colors.black87,
                ),
              ),
              SizedBox(height: 30),
              // Download Button
              if (attachment.isNotEmpty && attachment != 'null')
                ElevatedButton.icon(
                  onPressed: () {
                    // Handle download logic
                    downloadAttachment(attachment);
                  },
                  icon: Icon(Icons.download),
                  label: Text("Download Attachment"),
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  // Function to handle the download
  void downloadAttachment(String attachment) async {
    final url = '${baseUrl}uploads/$attachment'; // Replace with your attachment path
    print('Downloading: $url'); // Debug: Print download URL
    // Logic to download the file (use dio or flutter_downloader for file downloading)
  }
}


class AllNoticesPage extends StatelessWidget {
  final List<String> noticeTitles;
  final List<String> noticeDetails;

  AllNoticesPage({
    required this.noticeTitles,
    required this.noticeDetails,
  });

  // Helper function to format date and time
  String formatTime(String dateTime) {
    final date = DateTime.parse(dateTime);
    return DateFormat('hh:mm a').format(date); // Format time as "hh:mm AM/PM"
  }

  String formatDate(String dateTime) {
    final date = DateTime.parse(dateTime);
    return DateFormat('dd MMM\nyyy').format(date); // Format as "DD\nMMM"
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('All Notices'),
      ),
      body: ListView.builder(
        itemCount: noticeTitles.length,
        itemBuilder: (context, index) {
          // Extract date and time from noticeDetails
          final detailsParts = noticeDetails[index].split('\n');
          final dateTime = detailsParts[0].replaceAll('Date: ', '').trim();
          final formattedDate = formatDate(dateTime);
          final formattedTime = formatTime(dateTime);

          return GestureDetector(
            onTap: () {
              // Navigate to NoticeDetailsPage with the notice details
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => NoticeDetailsPage(
                    noticeTitle: noticeTitles[index],
                    noticeDetails: noticeDetails[index],
                  ),
                ),
              );
            },
            child: Card(
              margin: EdgeInsets.all(8.0),
              child: Padding(
                padding: const EdgeInsets.all(10.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Gradient square with date
                    Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Colors.blue, Colors.indigo],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      child: Center(
                        child: Text(
                          formattedDate,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 16),
                    // Title and time
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Title
                          Text(
                            noticeTitles[index],
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                          SizedBox(height: 8),
                          // Time
                          Text(
                            formattedTime,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                    Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
