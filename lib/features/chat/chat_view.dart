import 'package:flutter/material.dart';
import 'package:manager/resources/multimedia_resources/resources.dart';
import 'package:manager/widgets/common_app_bar.dart';
import 'package:manager/widgets/common_text_field.dart';
import '../../resources/app_resources/app_resources.dart';

// Message data model
class ChatMessage {
  final String id;
  final String text;
  final String timestamp;
  final bool isSent;
  final bool isRead;
  final String? translatedText;

  ChatMessage({
    required this.id,
    required this.text,
    required this.timestamp,
    required this.isSent,
    this.isRead = false,
    this.translatedText,
  });
}

class ChatView extends StatefulWidget {
  final String contactName;
  final String contactNumber;
  final String contactInitials;

  const ChatView({
    super.key,
    required this.contactName,
    required this.contactNumber,
    required this.contactInitials,
  });

  @override
  State<ChatView> createState() => _ChatViewState();
}

class _ChatViewState extends State<ChatView> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final FocusNode _messageFocusNode = FocusNode();

  // Dummy messages data
  final List<ChatMessage> _messages = [
    ChatMessage(
      id: '1',
      text: 'yes, I Need More help',
      timestamp: '01:08 PM',
      isSent: true,
      isRead: true,
    ),
    ChatMessage(
      id: '2',
      text:
          'thank you for your patience we will be with you as soon as our team is available',
      timestamp: '01:08 PM',
      isSent: false,
    ),
    ChatMessage(
      id: '3',
      text: 'yes, I Need More help',
      timestamp: '01:08 PM',
      isSent: true,
      isRead: true,
    ),
    ChatMessage(
      id: '4',
      text:
          'thank you for your patience we will be with you as soon as our team is available\nआपके धैर्य के लिए धन्यवाद, जैसे ही हमारी टीम उपलब्ध होगी हम आपके साथ होंगे',
      timestamp: '01:08 PM',
      isSent: false,
    ),
    ChatMessage(
      id: '5',
      text: 'yes, I Need More help',
      timestamp: '01:08 PM',
      isSent: true,
      isRead: true,
    ),
    ChatMessage(
      id: '6',
      text:
          'thank you for your patience we will be with you as soon as our team is available',
      timestamp: '01:08 PM',
      isSent: false,
    ),
  ];

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    _messageFocusNode.dispose();
    super.dispose();
  }

  void _handleAttachmentAction(String action) {
    // Handle different attachment actions
    switch (action) {
      case 'file':
        // Handle file selection
        break;
      case 'gallery':
        // Handle gallery selection
        break;
      case 'camera':
        // Handle camera
        break;
      case 'location':
        // Handle location sharing
        break;
      case 'video_call':
        // Handle video call
        break;
      case 'voice_call':
        // Handle voice call
        break;
    }
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return GradientAppBar(
      leading: IconButton(
        icon: Image.asset(
          AppImages.back,
          width: 24,
          height: 24,
          color: AppColors.white,
        ),
        onPressed: () => Navigator.of(context).pop(),
      ),
      titleWidget: Row(
        children: [
          Container(
            padding: EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.darkGray.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                widget.contactInitials,
                style: TextStyle(
                  color: AppColors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
          ),
          SizedBox(width: AppSizes.w12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    widget.contactName,
                    style: TextStyle(
                      color: AppColors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(width: AppSizes.w8),
                  Container(
                    width: 20,
                    height: 15,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(2),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(2),
                      child: Image.asset(AppImages.flag, fit: BoxFit.cover),
                    ),
                  ),
                ],
              ),
              Text(
                widget.contactNumber,
                style: TextStyle(color: AppColors.white, fontSize: 12),
              ),
            ],
          ),
        ],
      ),
      titleSpacing: 0,
      actions: [
        IconButton(
          icon: Image.asset(
            AppImages.search,
            width: 20,
            height: 20,
            color: AppColors.white,
          ),
          onPressed: () {
            // Handle search
          },
        ),
        IconButton(
          icon: Icon(Icons.more_vert, color: AppColors.white, size: 20),
          onPressed: () {
            // Handle more options
          },
        ),
      ],
    );
  }

  Widget _buildDateSeparator(String date) {
    return Center(
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: AppSizes.w12,
          vertical: AppSizes.h6,
        ),
        child: Text(
          date,
          style: TextStyle(
            color: AppColors.textSecondary,
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Widget _buildMessageBubble(ChatMessage message) {
    return TweenAnimationBuilder<double>(
      duration: Duration(milliseconds: 300),
      tween: Tween(begin: 0.0, end: 1.0),
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(0, 20 * (1 - value)),
          child: Opacity(
            opacity: value,
            child: Container(
              margin: EdgeInsets.symmetric(
                vertical: AppSizes.h2,
                horizontal: AppSizes.w16,
              ),
              child: Row(
                mainAxisAlignment:
                    message.isSent
                        ? MainAxisAlignment.end
                        : MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  // Message content
                  Flexible(
                    child: Column(
                      crossAxisAlignment:
                          message.isSent
                              ? CrossAxisAlignment.end
                              : CrossAxisAlignment.start,
                      children: [
                        // Message bubble
                        Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: () {
                              // Handle message tap (e.g., show options, copy text, etc.)
                            },
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(AppSizes.v18),
                              topRight: Radius.circular(AppSizes.v18),
                              bottomLeft:
                                  message.isSent
                                      ? Radius.circular(AppSizes.v18)
                                      : Radius.circular(0),
                              bottomRight:
                                  message.isSent
                                      ? Radius.circular(0)
                                      : Radius.circular(AppSizes.v18),
                            ),
                            child: Container(
                              constraints: BoxConstraints(
                                maxWidth:
                                    MediaQuery.of(context).size.width * 0.75,
                              ),
                              padding: EdgeInsets.symmetric(
                                horizontal: AppSizes.w16,
                                vertical: AppSizes.h12,
                              ),
                              decoration: BoxDecoration(
                                color:
                                    message.isSent
                                        ? AppColors.primaryDark
                                        : AppColors.primaryLight.withValues(
                                          alpha: 0.1,
                                        ),
                                borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(AppSizes.v18),
                                  topRight: Radius.circular(AppSizes.v18),
                                  bottomLeft:
                                      message.isSent
                                          ? Radius.circular(AppSizes.v18)
                                          : Radius.circular(0),
                                  bottomRight:
                                      message.isSent
                                          ? Radius.circular(0)
                                          : Radius.circular(AppSizes.v18),
                                ),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Message text
                                  Text(
                                    message.text,
                                    style: TextStyle(
                                      color:
                                          message.isSent
                                              ? AppColors.white
                                              : AppColors.textPrimary,
                                      fontSize: AppSizes.f14,
                                      height: 1.4,
                                      fontWeight: FontWeight.w400,
                                    ),
                                  ),

                                  // Translated text if available
                                  if (message.translatedText != null &&
                                      message.translatedText!.isNotEmpty) ...[
                                    SizedBox(height: AppSizes.h6),
                                    Container(
                                      padding: EdgeInsets.symmetric(
                                        horizontal: AppSizes.w8,
                                        vertical: AppSizes.h4,
                                      ),
                                      decoration: BoxDecoration(
                                        color:
                                            message.isSent
                                                ? AppColors.white.withValues(
                                                  alpha: 0.15,
                                                )
                                                : AppColors.lightGray
                                                    .withValues(alpha: 0.5),
                                        borderRadius: BorderRadius.circular(
                                          AppSizes.v8,
                                        ),
                                      ),
                                      child: Text(
                                        message.translatedText!,
                                        style: TextStyle(
                                          color:
                                              message.isSent
                                                  ? AppColors.white.withValues(
                                                    alpha: 0.9,
                                                  )
                                                  : AppColors.textSecondary,
                                          fontSize: AppSizes.f12,
                                          height: 1.3,
                                          fontStyle: FontStyle.italic,
                                        ),
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ),
                        ),

                        // Timestamp and status
                        Container(
                          margin: EdgeInsets.only(top: AppSizes.h4),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment:
                                message.isSent
                                    ? MainAxisAlignment.end
                                    : MainAxisAlignment.start,
                            children: [
                              Text(
                                "${message.timestamp} •",
                                style: TextStyle(
                                  color: AppColors.textGray,
                                  fontSize: AppSizes.f10,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              if (message.isSent) ...[
                                SizedBox(width: AppSizes.w6),
                                _buildMessageStatus(message),
                              ],
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildMessageStatus(ChatMessage message) {
    Color statusColor;

    if (message.isRead) {
      statusColor = AppColors.primary;
    } else {
      statusColor = AppColors.textGray;
    }

    return Text(
      message.isRead ? 'Read' : 'Sent',
      style: TextStyle(
        color: statusColor,
        fontSize: AppSizes.f10,
        fontWeight: FontWeight.w500,
      ),
    );
  }

  Widget _buildMessageInput() {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: AppSizes.w16,
        vertical: AppSizes.h12,
      ),
      decoration: BoxDecoration(
        color: AppColors.white,
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withValues(alpha: 0.08),
            offset: Offset(0, -2),
            blurRadius: 12,
            spreadRadius: 0,
          ),
        ],
      ),
      child: SafeArea(
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.lightGray.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(AppSizes.v24),
            border: Border.all(
              color:
                  _messageFocusNode.hasFocus
                      ? AppColors.primary.withValues(alpha: 0.3)
                      : Colors.transparent,
              width: 1,
            ),
          ),
          child: CommonTextField(
            controller: _messageController,
            placeholder: 'Write Message',
            prefixIcon: PopupMenuButton<String>(
              onSelected: (value) => _handleAttachmentAction(value),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppSizes.v23),
                side: BorderSide(
                  color: AppColors.textGray.withValues(alpha: 0.1),
                ),
              ),
              elevation: 0,
              position: PopupMenuPosition.over,
              offset: Offset(0, -370),
              menuPadding: EdgeInsets.zero,
              color: AppColors.white,
              itemBuilder:
                  (BuildContext context) => [
                    PopupMenuItem<String>(
                      value: 'file',
                      height: 34,
                      child: _buildAttachmentMenuItem(
                        icon: AppImages.file,
                        label: 'File',
                        color: AppColors.purple,
                        onTap: () {},
                      ),
                    ),
                    PopupMenuDivider(height: 0.5),
                    PopupMenuItem<String>(
                      value: 'gallery',
                      height: 34,
                      child: _buildAttachmentMenuItem(
                        icon: AppImages.gallery,
                        label: 'Album',
                        color: AppColors.primaryLight,
                        onTap: () {},
                      ),
                    ),
                    PopupMenuDivider(height: 0.5),
                    PopupMenuItem<String>(
                      value: 'camera',
                      height: 34,
                      child: _buildAttachmentMenuItem(
                        icon: AppImages.camera,
                        label: 'Camera',
                        color: AppColors.success,
                        onTap: () {},
                      ),
                    ),
                    PopupMenuDivider(height: 0.5),
                    PopupMenuItem<String>(
                      value: 'location',
                      height: 34,
                      child: _buildAttachmentMenuItem(
                        icon: AppImages.location,
                        label: 'Location',
                        color: AppColors.error,
                        onTap: () {},
                      ),
                    ),
                    PopupMenuDivider(height: 0.5),
                    PopupMenuItem<String>(
                      value: 'video_call',
                      height: 34,
                      child: _buildAttachmentMenuItem(
                        icon: AppImages.video,
                        label: 'Video Call',
                        color: AppColors.primary,
                        onTap: () {},
                      ),
                    ),
                    PopupMenuDivider(height: 0.5),
                    PopupMenuItem<String>(
                      value: 'voice_call',
                      height: 34,
                      child: _buildAttachmentMenuItem(
                        icon: AppImages.phone,
                        label: 'Voice Call',
                        color: AppColors.orange,
                        onTap: () {},
                      ),
                    ),
                  ],
              child: Container(
                margin: EdgeInsets.all(8),
                padding: EdgeInsets.all(5),
                decoration: BoxDecoration(
                  color: AppColors.lightGray.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Image.asset(
                  AppImages.attachment,
                  width: 20,
                  height: 20,
                  color: AppColors.primaryDark,
                ),
              ),
            ),
            suffixIcon: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Camera button
                GestureDetector(
                  onTap: () => _handleAttachmentAction('camera'),
                  child: Image.asset(
                    AppImages.cameraOutlined,
                    width: 20,
                    height: 20,
                    color: AppColors.primaryDark,
                  ),
                ),
                SizedBox(width: AppSizes.w12),
                // Microphone button
                GestureDetector(
                  onTap: () {
                    // Handle voice message
                  },
                  child: Image.asset(
                    AppImages.microphone,
                    width: 20,
                    height: 20,
                    color: AppColors.primaryDark,
                  ),
                ),
                SizedBox(width: AppSizes.w12),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAttachmentMenuItem({
    required String icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: AppSizes.w16,
        vertical: AppSizes.h12,
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(9),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(AppSizes.v10),
            ),
            child: Center(
              child: Image.asset(icon, width: 18, height: 18, color: color),
            ),
          ),
          SizedBox(width: AppSizes.w12),
          Text(
            label,
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: AppSizes.f14,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(context),
      backgroundColor: AppColors.white,
      body: Column(
        children: [
          // Messages list
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: EdgeInsets.only(top: AppSizes.h8),
              itemCount: _messages.length + 1, // +1 for date separator
              itemBuilder: (context, index) {
                if (index == 0) {
                  return _buildDateSeparator('Jun 17, 2025');
                }
                return _buildMessageBubble(_messages[index - 1]);
              },
            ),
          ),
          // Message input
          _buildMessageInput(),
        ],
      ),
    );
  }
}
