/*
* Copyright (c) 2012 Jason I. Carter
*
* Licensed under the Apache License, Version 2.0 (the "License");
* you may not use this file except in compliance with the License.
* You may obtain a copy of the License at
*
* http://www.apache.org/licenses/LICENSE-2.0
*
* Unless required by applicable law or agreed to in writing, software
* distributed under the License is distributed on an "AS IS" BASIS,
* WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
* See the License for the specific language governing permissions and
* limitations under the License.
*/


#ifndef INVITETODOWNLOAD_HPP_
#define INVITETODOWNLOAD_HPP_

#include <QtCore/QObject>

namespace bb {namespace platform {namespace bbm {class Context; class MessageService;}}}

/**
 * @brief A class that encapsulates the sending of the 'Invite to Download' message.
 */
class InviteToDownload: public QObject
{
Q_OBJECT


public:
        // Creates a new 'invite to download' object.
        InviteToDownload(bb::platform::bbm::Context *context);
        ~InviteToDownload();

        // This method is invoked to open the invitation dialog
        Q_INVOKABLE void sendInvite();

private:
        // The service object to send BBM messages
        bb::platform::bbm::MessageService * m_messageService;
        bb::platform::bbm::Context* m_context;

};

#endif /* INVITETODOWNLOAD_HPP_ */
