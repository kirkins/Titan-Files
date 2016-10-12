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

#include "InviteToDownload.hpp"

#include <bb/platform/bbm/MessageService>
#include <bb/system/SystemToast>
#include <bps/netstatus.h>

using namespace bb::system;

InviteToDownload::InviteToDownload(bb::platform::bbm::Context *context) :
                m_messageService(0), m_context(context) {
}

InviteToDownload::~InviteToDownload() {
        delete m_messageService;
}

void InviteToDownload::sendInvite() {
        bool is_available;
        netstatus_get_availability(&is_available);

        if (is_available) {

                if (!m_messageService) {
                        // Instantiate the MessageService.
                        m_messageService = new bb::platform::bbm::MessageService(m_context,
                                        this);
                }

                // Trigger the invite to download process.
                m_messageService->sendDownloadInvitation();
        } else {
                SystemToast *toast = new SystemToast(this);
                toast->setBody("No network connection available.");
                toast->show();
        }
}
