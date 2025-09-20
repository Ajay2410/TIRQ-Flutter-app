import 'package:flutter/material.dart';
import 'package:manager/resources/multimedia_resources/resources.dart';
import 'package:manager/widgets/common_app_bar.dart';
import 'package:manager/widgets/common_text_field.dart';
import 'package:manager/features/chat/chat.vm.dart';
import 'package:shimmer/shimmer.dart';
import 'package:stacked/stacked.dart';
import '../../resources/app_resources/app_resources.dart';
import '../../resources/enums/chat_enum.dart';
import '../../services/socket_service.dart';
import 'model/chat_message_model.dart';

class ChatView extends StatefulWidget {
  final String contactName;
  final String contactNumber;
  final String contactInitials;
  final String? roomId;

  const ChatView({super.key, required this.contactName, required this.contactNumber, required this.contactInitials, this.roomId});

  @override
  State<ChatView> createState() => _ChatViewState();
}

class _ChatViewState extends State<ChatView> {
  final FocusNode _messageFocusNode = FocusNode();

  @override
  void dispose() {
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
        icon: Image.asset(AppImages.back, width: 24, height: 24, color: AppColors.white),
        onPressed: () => Navigator.of(context).pop(),
      ),
      titleWidget: Row(
        children: [
          Container(
            padding: EdgeInsets.all(10),
            decoration: BoxDecoration(color: AppColors.darkGray.withValues(alpha: 0.2), shape: BoxShape.circle),
            child: Center(child: Text(widget.contactInitials, style: TextStyle(color: AppColors.white, fontWeight: FontWeight.bold, fontSize: 16))),
          ),
          SizedBox(width: AppSizes.w12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(widget.contactName, style: TextStyle(color: AppColors.white, fontSize: 16, fontWeight: FontWeight.w600)),
                  SizedBox(width: AppSizes.w8),
                  Container(
                    width: 20,
                    height: 15,
                    decoration: BoxDecoration(borderRadius: BorderRadius.circular(2)),
                    child: ClipRRect(borderRadius: BorderRadius.circular(2), child: Image.asset(AppImages.flag, fit: BoxFit.cover)),
                  ),
                ],
              ),
              Text(widget.contactNumber, style: TextStyle(color: AppColors.white, fontSize: 12)),
            ],
          ),
        ],
      ),
      titleSpacing: 0,
      actions: [
        IconButton(
          icon: Image.asset(AppImages.search, width: 20, height: 20, color: AppColors.white),
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
        padding: EdgeInsets.symmetric(horizontal: AppSizes.w12, vertical: AppSizes.h6),
        child: Text(date, style: TextStyle(color: AppColors.textSecondary, fontSize: 12, fontWeight: FontWeight.w500)),
      ),
    );
  }

  Widget _buildMessageBubble(ChatMessageModel message) {
    return TweenAnimationBuilder<double>(
      duration: Duration(milliseconds: 300),
      tween: Tween(begin: 0.0, end: 1.0),
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(0, 20 * (1 - value)),
          child: Opacity(
            opacity: value,
            child: Container(
              margin: EdgeInsets.symmetric(vertical: AppSizes.h2, horizontal: AppSizes.w16),
              child: Row(
                mainAxisAlignment: message.isSentByMe ? MainAxisAlignment.end : MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  // Message content
                  Flexible(
                    child: Column(
                      crossAxisAlignment: message.isSentByMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
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
                              bottomLeft: message.isSentByMe ? Radius.circular(AppSizes.v18) : Radius.circular(0),
                              bottomRight: message.isSentByMe ? Radius.circular(0) : Radius.circular(AppSizes.v18),
                            ),
                            child: Container(
                              constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
                              padding: EdgeInsets.symmetric(horizontal: AppSizes.w16, vertical: AppSizes.h12),
                              decoration: BoxDecoration(
                                color: message.isSentByMe ? AppColors.primaryDark : AppColors.primaryLight.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(AppSizes.v18),
                                  topRight: Radius.circular(AppSizes.v18),
                                  bottomLeft: message.isSentByMe ? Radius.circular(AppSizes.v18) : Radius.circular(0),
                                  bottomRight: message.isSentByMe ? Radius.circular(0) : Radius.circular(AppSizes.v18),
                                ),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Message text
                                  Text(
                                    message.content,
                                    style: TextStyle(
                                      color: message.isSentByMe ? AppColors.white : AppColors.textPrimary,
                                      fontSize: AppSizes.f14,
                                      height: 1.4,
                                      fontWeight: FontWeight.w400,
                                    ),
                                  ),

                                  // // Translated text if available
                                  // if (message.content.isNotEmpty) ...[
                                  //   SizedBox(height: AppSizes.h6),
                                  //   Container(
                                  //     padding: EdgeInsets.symmetric(
                                  //       horizontal: AppSizes.w8,
                                  //       vertical: AppSizes.h4,
                                  //     ),
                                  //     decoration: BoxDecoration(
                                  //       color:
                                  //           message.isSentByMe
                                  //               ? AppColors.white.withValues(
                                  //                 alpha: 0.15,
                                  //               )
                                  //               : AppColors.lightGray
                                  //                   .withValues(alpha: 0.5),
                                  //       borderRadius: BorderRadius.circular(
                                  //         AppSizes.v8,
                                  //       ),
                                  //     ),
                                  //     child: Text(
                                  //       message.content,
                                  //       style: TextStyle(
                                  //         color:
                                  //             message.isSentByMe
                                  //                 ? AppColors.white.withValues(
                                  //                   alpha: 0.9,
                                  //                 )
                                  //                 : AppColors.textSecondary,
                                  //         fontSize: AppSizes.f12,
                                  //         height: 1.3,
                                  //         fontStyle: FontStyle.italic,
                                  //       ),
                                  //     ),
                                  //   ),
                                  // ],
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
                            mainAxisAlignment: message.isSentByMe ? MainAxisAlignment.end : MainAxisAlignment.start,
                            children: [
                              Text(
                                "${_formatTimestamp(message.createdAt)} •",
                                style: TextStyle(color: AppColors.textGray, fontSize: AppSizes.f10, fontWeight: FontWeight.w500),
                              ),
                              if (message.isSentByMe) ...[SizedBox(width: AppSizes.w6), _buildMessageStatus(message)],
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

  Widget _buildMessageStatus(ChatMessageModel message) {
    Color statusColor;

    switch (message.status) {
      case MessageStatus.sent:
        statusColor = AppColors.textGray;
        break;
      case MessageStatus.delivered:
      case MessageStatus.read:
        statusColor = AppColors.primary;
        break;
      case MessageStatus.failed:
        statusColor = AppColors.error;
        break;
      case MessageStatus.unknown:
        statusColor = AppColors.textGray;
        break;
    }

    return Text(message.status.name.toUpperCase(), style: TextStyle(color: statusColor, fontSize: AppSizes.f10, fontWeight: FontWeight.w500));
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inDays > 0) {
      return '${timestamp.day}/${timestamp.month}';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }

  Widget _buildMessageInput(ChatViewModel model) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: AppSizes.w16, vertical: AppSizes.h12),
      decoration: BoxDecoration(
        color: AppColors.white,
        boxShadow: [BoxShadow(color: AppColors.black.withValues(alpha: 0.08), offset: Offset(0, -2), blurRadius: 12, spreadRadius: 0)],
      ),
      child: SafeArea(
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.lightGray.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(AppSizes.v24),
            border: Border.all(color: _messageFocusNode.hasFocus ? AppColors.primary.withValues(alpha: 0.3) : Colors.transparent, width: 1),
          ),
          child: CommonTextField(
            controller: model.messageController,
            placeholder: 'Write Message',
            // onFieldSubmitted: (value) => model.sendMessage(),
            prefixIcon: PopupMenuButton<String>(
              onSelected: (value) => _handleAttachmentAction(value),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppSizes.v23),
                side: BorderSide(color: AppColors.textGray.withValues(alpha: 0.1)),
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
                      child: _buildAttachmentMenuItem(icon: AppImages.file, label: 'File', color: AppColors.purple, onTap: () {}),
                    ),
                    PopupMenuDivider(height: 0.5),
                    PopupMenuItem<String>(
                      value: 'gallery',
                      height: 34,
                      child: _buildAttachmentMenuItem(icon: AppImages.gallery, label: 'Album', color: AppColors.primaryLight, onTap: () {}),
                    ),
                    PopupMenuDivider(height: 0.5),
                    PopupMenuItem<String>(
                      value: 'camera',
                      height: 34,
                      child: _buildAttachmentMenuItem(icon: AppImages.camera, label: 'Camera', color: AppColors.success, onTap: () {}),
                    ),
                    PopupMenuDivider(height: 0.5),
                    PopupMenuItem<String>(
                      value: 'location',
                      height: 34,
                      child: _buildAttachmentMenuItem(icon: AppImages.location, label: 'Location', color: AppColors.error, onTap: () {}),
                    ),
                    PopupMenuDivider(height: 0.5),
                    PopupMenuItem<String>(
                      value: 'video_call',
                      height: 34,
                      child: _buildAttachmentMenuItem(icon: AppImages.video, label: 'Video Call', color: AppColors.primary, onTap: () {}),
                    ),
                    PopupMenuDivider(height: 0.5),
                    PopupMenuItem<String>(
                      value: 'voice_call',
                      height: 34,
                      child: _buildAttachmentMenuItem(icon: AppImages.phone, label: 'Voice Call', color: AppColors.orange, onTap: () {}),
                    ),
                  ],
              child: Container(
                margin: EdgeInsets.all(8),
                padding: EdgeInsets.all(5),
                decoration: BoxDecoration(color: AppColors.lightGray.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(10)),
                child: Image.asset(AppImages.attachment, width: 20, height: 20, color: AppColors.primaryDark),
              ),
            ),
            suffixIcon: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Camera button
                GestureDetector(
                  onTap: () => _handleAttachmentAction('camera'),
                  child: Image.asset(AppImages.cameraOutlined, width: 20, height: 20, color: AppColors.primaryDark),
                ),
                SizedBox(width: AppSizes.w12),
                // Microphone button
                GestureDetector(
                  onTap: () {
                    // Handle voice message
                  },
                  child: Image.asset(AppImages.microphone, width: 20, height: 20, color: AppColors.primaryDark),
                ),
                SizedBox(width: AppSizes.w12),
                GestureDetector(
                  onTap:
                      model.isSendingMessage
                          ? null
                          : () {
                            // Send message when send button is tapped
                            if (model.messageController.text.trim().isNotEmpty) {
                              model.sendMessage();
                            }
                          },
                  child: Container(
                    padding: EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color:
                          model.messageController.text.trim().isNotEmpty && !model.isSendingMessage
                              ? AppColors.primaryDark
                              : AppColors.lightGray.withValues(alpha: 0.3),
                      shape: BoxShape.circle,
                    ),
                    child:
                        model.isSendingMessage
                            ? SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2, valueColor: AlwaysStoppedAnimation<Color>(AppColors.white)),
                            )
                            : Image.asset(
                              AppImages.send,
                              width: 16,
                              height: 16,
                              color: model.messageController.text.trim().isNotEmpty ? AppColors.white : AppColors.textGray,
                            ),
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

  Widget _buildAttachmentMenuItem({required String icon, required String label, required Color color, required VoidCallback onTap}) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: AppSizes.w16, vertical: AppSizes.h12),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(9),
            decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(AppSizes.v10)),
            child: Center(child: Image.asset(icon, width: 18, height: 18, color: color)),
          ),
          SizedBox(width: AppSizes.w12),
          Text(label, style: TextStyle(color: AppColors.textPrimary, fontSize: AppSizes.f14, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<ChatViewModel>.reactive(
      viewModelBuilder: () => ChatViewModel(),
      onViewModelReady: (model) {
        model.fetchInitialData(roomId1: widget.roomId);

        // Add some sample messages for demonstration
        // model.addSampleMessage();

        // Add listener to text controller for dynamic UI updates
        model.messageController.addListener(() {
          setState(() {
            // This will trigger a rebuild to update the send button appearance
          });
        });
      },
      builder:
          (context, model, child) => Scaffold(
            appBar: _buildAppBar(context),
            backgroundColor: AppColors.white,
            body: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                // Messages list
                Flexible(
                  child:
                      model.isLoading
                          ? ListView.builder(
                            controller: model.scrollController,
                            padding: EdgeInsets.only(top: AppSizes.h8),
                            itemCount: model.isLoading ? 6 : model.messages.length + 1, // +1 for date separator
                            itemBuilder: (context, index) {
                              if (model.isLoading) {
                                // Alternate shimmer sides for variety
                                return MessageBubbleShimmer(isSentByMe: index % 2 == 0);
                              }

                              if (index == 0) {
                                return _buildDateSeparator('Today');
                              }

                              final message = model.messages[index - 1];
                              return _buildMessageBubble(message);
                            },
                          )
                          : ListView.builder(
                            controller: model.scrollController,
                            padding: EdgeInsets.only(top: AppSizes.h10),
                            itemCount: model.messages.length + 1, // +1 for date separator
                            itemBuilder: (context, index) {
                              if (index == 0) {
                                return _buildDateSeparator('Today');
                              }
                              final message = model.messages[index - 1];
                              return _buildMessageBubble(message);
                            },
                          ),
                ),
                // Message input
                _buildMessageInput(model),
              ],
            ),
          ),
    );
  }
}

class MessageBubbleShimmer extends StatelessWidget {
  final bool isSentByMe;

  const MessageBubbleShimmer({super.key, required this.isSentByMe});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade300,
      highlightColor: Colors.grey.shade100,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 16),
        child: Row(
          mainAxisAlignment: isSentByMe ? MainAxisAlignment.end : MainAxisAlignment.start,
          children: [
            Flexible(
              child: Column(
                crossAxisAlignment: isSentByMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                children: [
                  // Message bubble shimmer
                  Container(
                    constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.only(
                        topLeft: const Radius.circular(18),
                        topRight: const Radius.circular(18),
                        bottomLeft: isSentByMe ? const Radius.circular(18) : const Radius.circular(0),
                        bottomRight: isSentByMe ? const Radius.circular(0) : const Radius.circular(18),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(height: 12, width: double.infinity, color: Colors.white),
                        const SizedBox(height: 6),
                        Container(height: 12, width: 80, color: Colors.white),
                      ],
                    ),
                  ),
                  const SizedBox(height: 4),
                  // Timestamp shimmer
                  Container(height: 10, width: 50, color: Colors.white),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
